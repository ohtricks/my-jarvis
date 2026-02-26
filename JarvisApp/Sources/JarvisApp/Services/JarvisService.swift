import AVFoundation
import Foundation
import Observation

@Observable
class JarvisService: NSObject, AVAudioRecorderDelegate {
    var messages: [Message] = []
    var isProcessing = false
    var statusText = "online"

    private let baseURL = "http://localhost:8000"
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?

    // MARK: — Chat por texto

    func sendText(_ text: String) async {
        addMessage(Message(role: .user, text: text))
        statusText = "processando"

        guard let url = URL(string: "\(baseURL)/chat/text") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["message": text])

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let response = json["response"] as? String {
                addMessage(Message(role: .jarvis, text: response))
            }
        } catch {
            addMessage(Message(role: .jarvis, text: "Falha na conexão com o servidor."))
        }
        statusText = "online"
    }

    // MARK: — Gravação de voz

    func startRecording() {
        let tempDir = FileManager.default.temporaryDirectory
        recordingURL = tempDir.appendingPathComponent("jarvis_input_\(UUID().uuidString).wav")
        guard let url = recordingURL else { return }

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            statusText = "gravando"
        } catch {
            statusText = "erro ao gravar"
        }
    }

    func cancelRecording() {
        audioRecorder?.stop()
        audioRecorder?.deleteRecording()
        audioRecorder = nil
        recordingURL = nil
        statusText = "online"
    }

    func stopRecordingAndSend() {
        audioRecorder?.stop()
        audioRecorder = nil
        guard let url = recordingURL else { return }
        Task { await sendAudio(url: url) }
    }

    func sendAudio(url: URL) async {
        isProcessing = true
        statusText = "transcrevendo"

        defer {
            isProcessing = false
            statusText = "online"
            try? FileManager.default.removeItem(at: url)
        }

        guard let audioData = try? Data(contentsOf: url),
              let endpoint = URL(string: "\(baseURL)/chat/voice") else { return }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"input.wav\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") ?? ""

                // Backend retornou JSON de erro em vez de áudio
                if contentType.contains("application/json") {
                    let detail: String
                    if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                       let errorMsg = json["error"] as? String {
                        detail = errorMsg
                    } else {
                        detail = String(data: responseData, encoding: .utf8) ?? "resposta inválida"
                    }
                    addMessage(Message(role: .jarvis, text: "⚠️ Erro: \(detail)"))
                } else {
                    // Resposta de áudio normal
                    let transcription = httpResponse.value(forHTTPHeaderField: "X-Transcription") ?? ""
                    let jarvisResponse = httpResponse.value(forHTTPHeaderField: "X-Response") ?? ""
                    if !transcription.isEmpty { addMessage(Message(role: .user, text: transcription)) }
                    if !jarvisResponse.isEmpty { addMessage(Message(role: .jarvis, text: jarvisResponse)) }
                    playAudio(data: responseData)
                }
            }
        } catch {
            addMessage(Message(role: .jarvis, text: "⚠️ Falha de rede: \(error.localizedDescription)"))
        }
    }

    // MARK: — Utilitários

    func clearMemory() async {
        guard let url = URL(string: "\(baseURL)/memory") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try? await URLSession.shared.data(for: request)
        messages.removeAll()
        statusText = "memória limpa"
        try? await Task.sleep(for: .seconds(1.5))
        statusText = "online"
    }

    private func addMessage(_ message: Message) {
        DispatchQueue.main.async { self.messages.append(message) }
    }

    private func playAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.play()
        } catch {}
    }
}

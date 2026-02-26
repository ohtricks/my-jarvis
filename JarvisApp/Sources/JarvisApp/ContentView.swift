import AppKit
import SwiftUI

// Fix de foco: NSView que aceita o primeiro clique sem exigir que a janela
// já seja key — resolve o bug de teclado indo para a janela de trás.
struct FirstMouseEnabler: NSViewRepresentable {
    func makeNSView(context: Context) -> _FirstMouseNSView { _FirstMouseNSView() }
    func updateNSView(_ nsView: _FirstMouseNSView, context: Context) {}
}
class _FirstMouseNSView: NSView {
    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

struct ContentView: View {
    @State private var service = JarvisService()
    @State private var inputText = ""
    @State private var micState: MicState = .idle
    @State private var recordingSeconds = 0
    @State private var recordingTimer: Timer?
    @FocusState private var inputFocused: Bool

    // Paleta JARVIS HUD
    private let bg          = Color(hex: "#070B14")
    private let headerBg    = Color(hex: "#080E1C")
    private let cyan        = Color(hex: "#00D4FF")
    private let accent      = Color(hex: "#1565D8")

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Divider().overlay(cyan.opacity(0.12))
                chatArea
                Divider().overlay(cyan.opacity(0.12))
                inputArea
            }
        }
        .frame(minWidth: 420, idealWidth: 480, minHeight: 540, idealHeight: 680)
        // Fix de foco: FirstMouseEnabler garante que o primeiro clique já
        // passa para o controle correto sem precisar de um segundo clique.
        .background(FirstMouseEnabler())
        .onChange(of: service.isProcessing) { _, processing in
            if !processing && micState == .processing {
                withAnimation(.spring(duration: 0.3)) { micState = .idle }
            }
        }
    }

    // MARK: — Header

    private var header: some View {
        HStack(spacing: 10) {
            // Logo JARVIS
            HStack(spacing: 7) {
                ZStack {
                    Circle()
                        .fill(cyan.opacity(0.08))
                        .frame(width: 26, height: 26)
                    Circle()
                        .strokeBorder(cyan.opacity(0.4), lineWidth: 1)
                        .frame(width: 26, height: 26)
                    Image(systemName: "cpu")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(cyan)
                }
                Text("J.A.R.V.I.S.")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .tracking(2)
            }

            Spacer()

            // Status pill
            HStack(spacing: 5) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 5, height: 5)
                Text(service.statusText)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(hex: "#4A7FA0"))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(hex: "#0A1628"), in: Capsule())
            .overlay(Capsule().strokeBorder(Color(hex: "#1A3050"), lineWidth: 1))

            // Botão limpar
            Button {
                Task { await service.clearMemory() }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "#3A5A7A"))
                    .frame(width: 28, height: 28)
                    .background(Color(hex: "#0A1628"), in: Circle())
                    .overlay(Circle().strokeBorder(Color(hex: "#1A3050"), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .help("Limpar conversa")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(headerBg)
    }

    // MARK: — Chat

    private var chatArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 6) {
                    if service.messages.isEmpty {
                        emptyState
                    } else {
                        ForEach(service.messages) { msg in
                            ChatBubble(message: msg)
                                .id(msg.id)
                                .transition(.asymmetric(
                                    insertion: .move(edge: msg.role == .user ? .trailing : .leading)
                                        .combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                }
                .padding(.vertical, 14)
                .animation(.spring(duration: 0.35), value: service.messages.count)
            }
            .scrollContentBackground(.hidden)
            .onChange(of: service.messages.count) { _, _ in
                if let last = service.messages.last {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
        .background(bg)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(cyan.opacity(0.04))
                    .frame(width: 72, height: 72)
                Circle()
                    .strokeBorder(cyan.opacity(0.15), lineWidth: 1)
                    .frame(width: 72, height: 72)
                Image(systemName: "waveform")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundStyle(cyan.opacity(0.5))
            }
            Text("Como posso ajudar, senhor?")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(hex: "#3A6080"))
            Text("Digite ou use o microfone para falar.")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color(hex: "#1E3A5F"))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: — Input

    private var inputArea: some View {
        VStack(spacing: 0) {
            if micState == .recording {
                // Barra de gravação estilo WhatsApp
                RecordingBar(
                    seconds: recordingSeconds,
                    onCancel: {
                        stopRecordingTimer()
                        service.cancelRecording()
                        withAnimation(.spring(duration: 0.3)) { micState = .idle }
                    },
                    onSend: {
                        stopRecordingTimer()
                        service.stopRecordingAndSend()
                        withAnimation(.spring(duration: 0.3)) { micState = .processing }
                    }
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            } else {
                // Barra de texto normal
                HStack(spacing: 10) {
                    // Campo de texto
                    ZStack(alignment: .leading) {
                        if inputText.isEmpty {
                            Text("Mensagem...")
                                .font(.system(size: 13))
                                .foregroundStyle(Color(hex: "#2A4A6A"))
                                .padding(.horizontal, 14)
                                .allowsHitTesting(false)
                        }
                        TextField("", text: $inputText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(hex: "#C8DCF0"))
                            .lineLimit(1...4)
                            .focused($inputFocused)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .onSubmit { sendText() }
                    }
                    .background(Color(hex: "#0A1628"), in: RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(
                                inputFocused ? cyan.opacity(0.3) : Color(hex: "#1A3050"),
                                lineWidth: 1
                            )
                    )
                    .animation(.easeInOut(duration: 0.15), value: inputFocused)
                    .onTapGesture { inputFocused = true }

                    // Botão microfone
                    if micState == .processing {
                        ProgressView()
                            .controlSize(.small)
                            .tint(cyan)
                            .frame(width: 38, height: 38)
                    } else {
                        Button {
                            guard micState == .idle else { return }
                            inputFocused = false
                            service.startRecording()
                            startRecordingTimer()
                            withAnimation(.spring(duration: 0.3)) { micState = .recording }
                        } label: {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color(hex: "#4A7FA0"))
                                .frame(width: 38, height: 38)
                                .background(Color(hex: "#0A1628"), in: Circle())
                                .overlay(Circle().strokeBorder(Color(hex: "#1A3050"), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .help("Clique para gravar")
                    }

                    // Botão enviar
                    Button(action: sendText) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(canSend ? .white : Color(hex: "#1E3A5F"))
                            .frame(width: 38, height: 38)
                            .background(
                                canSend
                                    ? LinearGradient(colors: [Color(hex: "#1565D8"), Color(hex: "#0D4FC0")],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color(hex: "#0A1628")],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: Circle()
                            )
                            .overlay(Circle().strokeBorder(
                                canSend ? Color.clear : Color(hex: "#1A3050"), lineWidth: 1
                            ))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSend)
                    .animation(.easeInOut(duration: 0.15), value: canSend)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
        }
        .background(headerBg)
    }

    // MARK: — Helpers

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespaces).isEmpty && micState == .idle
    }

    private var statusColor: Color {
        switch service.statusText {
        case "online":        return Color(hex: "#22C55E")
        case "gravando":      return Color.red
        case "processando",
             "transcrevendo": return Color(hex: "#F59E0B")
        default:              return Color(hex: "#4A7FA0")
        }
    }

    private func sendText() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, micState == .idle else { return }
        inputText = ""
        inputFocused = true
        Task { await service.sendText(text) }
    }

    private func startRecordingTimer() {
        recordingSeconds = 0
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingSeconds += 1
        }
    }

    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingSeconds = 0
    }
}

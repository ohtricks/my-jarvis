import SwiftUI

// Estados do microfone — estilo WhatsApp
enum MicState {
    case idle, recording, processing
}

struct RecordingBar: View {
    let seconds: Int
    var onCancel: () -> Void
    var onSend: () -> Void

    @State private var pulse = false

    var body: some View {
        HStack(spacing: 12) {
            // Indicador pulsante
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.25))
                    .frame(width: 28, height: 28)
                    .scaleEffect(pulse ? 1.4 : 1.0)
                    .opacity(pulse ? 0 : 1)
                    .animation(.easeOut(duration: 0.9).repeatForever(autoreverses: false), value: pulse)
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
            }
            .onAppear { pulse = true }

            Text(timeString(seconds))
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.red.opacity(0.9))
                .frame(minWidth: 36, alignment: .leading)

            Spacer()

            // Cancelar
            Button(action: onCancel) {
                HStack(spacing: 5) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                    Text("Cancelar")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(Color(hex: "#8FA8C8"))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color(hex: "#0D1B2E"), in: Capsule())
                .overlay(Capsule().strokeBorder(Color(hex: "#1E3A5F"), lineWidth: 1))
            }
            .buttonStyle(.plain)

            // Enviar
            Button(action: onSend) {
                HStack(spacing: 5) {
                    Text("Enviar")
                        .font(.system(size: 12, weight: .semibold))
                    Image(systemName: "arrow.up")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    LinearGradient(colors: [Color(hex: "#1565D8"), Color(hex: "#0D4FC0")],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: Capsule()
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(hex: "#080E1C"), in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(Color.red.opacity(0.2), lineWidth: 1))
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}

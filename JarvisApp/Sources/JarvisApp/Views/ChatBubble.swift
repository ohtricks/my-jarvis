import SwiftUI

struct ChatBubble: View {
    let message: Message
    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if isUser { Spacer(minLength: 56) }

            if !isUser {
                // Ícone JARVIS
                ZStack {
                    Circle()
                        .fill(Color(hex: "#0A1628"))
                        .frame(width: 28, height: 28)
                    Circle()
                        .strokeBorder(Color(hex: "#00D4FF").opacity(0.5), lineWidth: 1)
                        .frame(width: 28, height: 28)
                    Image(systemName: "cpu")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "#00D4FF"))
                }
                .padding(.bottom, 2)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .font(.system(size: 13.5))
                    .foregroundStyle(isUser ? .white : Color(hex: "#D8E4F0"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(bubbleBackground)
                    .clipShape(bubbleShape)
                    .textSelection(.enabled)

                Text(message.timestamp, style: .time)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.2))
                    .padding(.horizontal, 4)
            }

            if !isUser { Spacer(minLength: 56) }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if isUser {
            LinearGradient(
                colors: [Color(hex: "#1565D8"), Color(hex: "#0D4FC0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            Color(hex: "#0D1B2E")
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(hex: "#1E3A5F").opacity(0.8), lineWidth: 1)
                )
        }
    }

    private var bubbleShape: some Shape {
        UnevenRoundedRectangle(
            topLeadingRadius: 16,
            bottomLeadingRadius: isUser ? 16 : 4,
            bottomTrailingRadius: isUser ? 4 : 16,
            topTrailingRadius: 16
        )
    }
}

// Extensão para hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

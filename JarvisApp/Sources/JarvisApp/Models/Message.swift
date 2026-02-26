import Foundation

enum MessageRole {
    case user, jarvis
}

struct Message: Identifiable {
    let id = UUID()
    let role: MessageRole
    let text: String
    let timestamp = Date()
}

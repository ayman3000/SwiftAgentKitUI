import SwiftUI

/// A message bubble for displaying user and assistant messages.
public struct MessageBubble: View {
    let message: ChatMessage

    public init(message: ChatMessage) {
        self.message = message
    }

    public var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(message.isError ? Color.red : Color.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.role == .user
                            ? Color.accentColor.opacity(0.15)
                            : Color.secondary.opacity(0.1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                if message.isStreaming {
                    Text("●●●")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                }
            }

            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 12)
    }
}

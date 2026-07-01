import SwiftUI

/// The input bar with text field and send/cancel button.
struct InputBar: View {
    @Binding var text: String
    let isRunning: Bool
    let onSend: () -> Void
    let onCancel: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            TextField("Message the agent…", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .onSubmit {
                    if !isRunning {
                        onSend()
                    }
                }

            if isRunning {
                Button(action: onCancel) {
                    Image(systemName: "stop.fill")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.cancelAction)
            } else {
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.borderless)
                .keyboardShortcut(.return)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}
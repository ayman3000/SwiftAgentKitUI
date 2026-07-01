import SwiftUI

/// A timeline view showing tool calls, their execution status, and results.
struct ToolCallTimeline: View {
    let events: [ToolCallEvent]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                Text("Tool Calls")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)

                ForEach(events) { event in
                    ToolCallRow(event: event)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

struct ToolCallRow: View {
    let event: ToolCallEvent

    var body: some View {
        HStack(spacing: 8) {
            // Status indicator
            statusIcon
                .frame(width: 16, height: 16)

            // Tool name
            Text(event.name)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)

            Spacer()

            // Result preview (truncated)
            if let result = event.result, !result.isEmpty {
                Text(result.prefix(60))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch event.status {
        case .pending:
            Image(systemName: "circle")
                .font(.caption2)
                .foregroundStyle(.secondary)
        case .running:
            ProgressView()
                .scaleEffect(0.5)
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .font(.caption2)
                .foregroundStyle(.green)
        case .error:
            Image(systemName: "xmark.circle.fill")
                .font(.caption2)
                .foregroundStyle(.red)
        }
    }
}
import SwiftUI
import SwiftAgentKit

/// A debug panel showing the agent's event stream in real time.
///
/// Useful for development and debugging — shows every event the agent emits:
/// LLM calls, tool calls, tool results, planning, repair retries, history trimming.
///
/// Usage:
/// ```swift
/// AgentEventView(agent: agent)
/// ```
public struct AgentEventView: View {
    let agent: Agent
    @State private var events: [EventEntry] = []
    @State private var isAutoScroll = true

    public init(agent: Agent) {
        self.agent = agent
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Event Timeline")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Spacer()

                Toggle("Auto-scroll", isOn: $isAutoScroll)
                    .toggleStyle(.switch)
                    .controlSize(.mini)

                Button("Clear") {
                    events.removeAll()
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)

            Divider()

            // Event list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(events) { entry in
                            EventRow(entry: entry)
                                .id(entry.id)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }
                .onChange(of: events.count) { _ in
                    if isAutoScroll {
                        proxy.scrollTo(events.last?.id, anchor: .bottom)
                    }
                }
            }
        }
        .onAppear {
            agent.onEvent { event in
                Task { @MainActor in
                    events.append(EventEntry(from: event))
                }
            }
        }
    }
}

// MARK: - Event Entry

struct EventEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let icon: String
    let color: Color
    let title: String
    let detail: String?

    init(from event: AgentEvent) {
        timestamp = Date()
        switch event {
        case .started(let query):
            icon = "play.circle"
            color = .blue
            title = "Started"
            detail = query.prefix(80).description
        case .finished(let summary):
            icon = "checkmark.circle"
            color = .green
            title = "Finished"
            detail = "\(summary.totalTurns) turns, \(summary.toolsExecuted) tools, \(String(format: "%.1f", summary.elapsed))s"
        case .cancelled:
            icon = "xmark.circle"
            color = .red
            title = "Cancelled"
            detail = nil
        case .llmCallStarted(let turn):
            icon = "brain"
            color = .orange
            title = "LLM call — turn \(turn)"
            detail = nil
        case .llmCallCompleted(let turn, let response):
            icon = "brain.head.profile"
            color = .orange
            title = "LLM completed — turn \(turn)"
            detail = response.text.prefix(80).description
        case .toolCallsReceived(let calls):
            icon = "wrench.and.screwdriver"
            color = .purple
            title = "Tool calls: \(calls.map(\.name).joined(separator: ", "))"
            detail = nil
        case .toolExecutionStarted(let call):
            icon = "hammer"
            color = .yellow
            title = "Executing: \(call.name)"
            detail = nil
        case .toolExecutionFinished(let call, let result):
            icon = result.isError ? "exclamationmark.triangle" : "checkmark"
            color = result.isError ? .red : .green
            title = "Finished: \(call.name)"
            detail = result.result.prefix(80).description
        case .toolCallSkippedDuplicate(let call):
            icon = "arrow.uturn.right"
            color = .gray
            title = "Skipped duplicate: \(call.name)"
            detail = nil
        case .planningStarted:
            icon = "list.bullet.clipboard"
            color = .indigo
            title = "Planning started"
            detail = nil
        case .planGenerated(let steps):
            icon = "list.bullet.clipboard"
            color = .indigo
            title = "Plan generated"
            detail = steps.joined(separator: " → ").prefix(80).description
        case .planStepUpdated(let index, _, let status):
            icon = "checkmark.circle"
            color = .teal
            title = "Step \(index) → \(status)"
            detail = nil
        case .repairRetryTriggered(let errors, let attempt):
            icon = "arrow.clockwise"
            color = .orange
            title = "Repair retry #\(attempt)"
            detail = "\(errors.count) error(s)"
        case .planContinuationTriggered(let pending, let attempt):
            icon = "arrow.forward"
            color = .orange
            title = "Plan continuation #\(attempt)"
            detail = "\(pending.count) pending step(s)"
        case .historyTrimmed(let removed, let remaining):
            icon = "scissors"
            color = .gray
            title = "History trimmed"
            detail = "−\(removed) messages, \(remaining) remaining"
        case .skillsActivated(let names):
            icon = "sparkles"
            color = .pink
            title = "Skills activated"
            detail = names.joined(separator: ", ")
        case .streamChunk(let chunk):
            icon = "text.alignleft"
            color = .blue
            title = "Stream chunk"
            detail = chunk.prefix(60).description
        case .streamFinished:
            icon = "checkmark"
            color = .blue
            title = "Stream finished"
            detail = nil
        case .llmCallRetrying(let turn, let attempt, let error):
            icon = "arrow.clockwise"
            color = .orange
            title = "Retrying — turn \(turn), attempt \(attempt)"
            detail = error.prefix(80).description
        case .providerFallback(let from, let to):
            icon = "arrow.left.arrow.right"
            color = .orange
            title = "Provider fallback: \(from) → \(to)"
            detail = nil
        case .toolConfirmationRequired:
            icon = "hand.raised"
            color = .yellow
            title = "Tool confirmation required"
            detail = nil
        }
    }
}

// MARK: - Event Row

struct EventRow: View {
    let entry: EventEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: entry.icon)
                .font(.caption2)
                .foregroundStyle(entry.color)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 1) {
                Text(entry.title)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.primary)

                if let detail = entry.detail {
                    Text(detail)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Text(entry.timestamp, style: .time)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 1)
    }
}
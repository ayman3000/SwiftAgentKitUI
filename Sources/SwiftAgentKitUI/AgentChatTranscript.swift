import SwiftAgentKit

struct AgentChatTranscript {
    var messages: [ChatMessage] = []
    var isRunning = false
    var toolCallEvents: [ToolCallEvent] = []
    var currentTurn = 0
    var streamingText = ""

    mutating func startSubmittedQuery(_ query: String) {
        appendUserMessageIfNeeded(query)
        isRunning = true
        streamingText = ""
        toolCallEvents = []
    }

    mutating func handleEvent(_ event: AgentEvent, ignoresStreamChunks: Bool = false) {
        switch event {
        case .started(let query):
            appendUserMessageIfNeeded(query)
            isRunning = true
            streamingText = ""
            toolCallEvents = []

        case .llmCallStarted(let turn):
            currentTurn = turn

        case .toolCallsReceived(let calls):
            for call in calls {
                toolCallEvents.append(ToolCallEvent(
                    name: call.name,
                    status: .pending
                ))
            }

        case .toolExecutionStarted(let call):
            updateToolCallEvent(name: call.name, status: .running)

        case .toolExecutionFinished(let call, let result):
            updateToolCallEvent(
                name: call.name,
                status: result.isError ? .error : .done,
                result: result.result
            )

        case .streamChunk(let chunk):
            if !ignoresStreamChunks {
                streamingText += chunk
            }

        case .finished:
            finishRun()

        default:
            break
        }
    }

    mutating func appendRunStreamingChunk(_ chunk: String) {
        streamingText += chunk
    }

    mutating func finishRun() {
        appendStreamingMessageIfNeeded()
        isRunning = false
        currentTurn = 0
    }

    mutating func failRun(_ error: Error) {
        messages.append(ChatMessage(
            role: .assistant,
            text: "Error: \(error.localizedDescription)",
            isError: true
        ))
        isRunning = false
        streamingText = ""
    }

    mutating func cancelRun() {
        isRunning = false
        if !streamingText.isEmpty {
            messages.append(ChatMessage(role: .assistant, text: streamingText + " [cancelled]"))
            streamingText = ""
        }
    }

    private mutating func appendUserMessageIfNeeded(_ query: String) {
        if messages.last?.role == .user && messages.last?.text == query {
            return
        }
        messages.append(ChatMessage(role: .user, text: query))
    }

    private mutating func appendStreamingMessageIfNeeded() {
        if !streamingText.isEmpty {
            messages.append(ChatMessage(role: .assistant, text: streamingText, isStreaming: false))
            streamingText = ""
        }
    }

    private mutating func updateToolCallEvent(name: String, status: ToolCallStatus, result: String? = nil) {
        if let idx = toolCallEvents.lastIndex(where: { $0.name == name && $0.status != .done && $0.status != .error }) {
            toolCallEvents[idx].status = status
            if let result = result {
                toolCallEvents[idx].result = result
            }
        }
    }
}

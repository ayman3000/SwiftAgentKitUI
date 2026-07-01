import SwiftUI
import SwiftAgentKit

/// A ready-made agent chat view for SwiftUI apps.
///
/// Drop this into any macOS or iOS app to get a full agent chat experience:
/// - Message bubbles for user and assistant
/// - Tool call timeline with status indicators
/// - Input field with send/cancel
/// - Optional streaming support
/// - Event timeline for debugging
///
/// Usage:
/// ```swift
/// let agent = Agent(config: AgentConfig(provider: provider, maxTurns: 6))
/// agent.register(MyTool())
///
/// AgentChatView(agent: agent)
/// ```
public struct AgentChatView: View {
    let agent: Agent
    let configuration: AgentChatConfiguration

    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isRunning = false
    @State private var toolCallEvents: [ToolCallEvent] = []
    @State private var currentTurn: Int = 0
    @State private var streamingText: String = ""

    public init(agent: Agent, configuration: AgentChatConfiguration = .default) {
        self.agent = agent
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Message list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { msg in
                            MessageBubble(message: msg)
                                .id(msg.id)
                        }

                        // Streaming text preview
                        if isRunning && !streamingText.isEmpty && configuration.showStreamingPreview {
                            MessageBubble(message: ChatMessage(
                                role: .assistant,
                                text: streamingText,
                                isStreaming: true
                            ))
                            .id("streaming")
                        }

                        // Loading indicator
                        if isRunning && streamingText.isEmpty {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Thinking…")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onChange(of: messages.count) { _ in
                    withAnimation {
                        if let lastId = messages.last?.id {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: streamingText) { _ in
                    withAnimation {
                        proxy.scrollTo("streaming", anchor: .bottom)
                    }
                }
            }

            // Tool call timeline (optional)
            if configuration.showToolCalls && !toolCallEvents.isEmpty {
                Divider()
                ToolCallTimeline(events: toolCallEvents)
                    .frame(maxHeight: configuration.toolCallTimelineHeight)
            }

            // Input bar
            Divider()
            InputBar(
                text: $inputText,
                isRunning: isRunning,
                onSend: sendMessage,
                onCancel: cancelRun
            )
        }
        .onAppear {
            setupEventObserver()
        }
    }

    // MARK: - Setup

    private func setupEventObserver() {
        agent.onEvent { event in
            Task { @MainActor in
                handleEvent(event)
            }
        }
    }

    // MARK: - Event Handling

    private func handleEvent(_ event: AgentEvent) {
        switch event {
        case .started(let query):
            messages.append(ChatMessage(role: .user, text: query))
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
            streamingText += chunk

        case .finished:
            if !streamingText.isEmpty {
                messages.append(ChatMessage(role: .assistant, text: streamingText, isStreaming: false))
                streamingText = ""
            }
            isRunning = false
            currentTurn = 0

        default:
            break
        }
    }

    private func updateToolCallEvent(name: String, status: ToolCallStatus, result: String? = nil) {
        if let idx = toolCallEvents.lastIndex(where: { $0.name == name && $0.status != .done && $0.status != .error }) {
            toolCallEvents[idx].status = status
            if let result = result {
                toolCallEvents[idx].result = result
            }
        }
    }

    // MARK: - Actions

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""

        Task {
            do {
                if configuration.useStreaming {
                    for try await chunk in agent.runStreaming(text) {
                        await MainActor.run {
                            streamingText += chunk
                        }
                    }
                    await MainActor.run {
                        if !streamingText.isEmpty {
                            messages.append(ChatMessage(role: .assistant, text: streamingText))
                            streamingText = ""
                        }
                        isRunning = false
                    }
                } else {
                    let response = try await agent.run(text)
                    await MainActor.run {
                        messages.append(ChatMessage(role: .assistant, text: response))
                        isRunning = false
                    }
                }
            } catch {
                await MainActor.run {
                    messages.append(ChatMessage(
                        role: .assistant,
                        text: "Error: \(error.localizedDescription)",
                        isError: true
                    ))
                    isRunning = false
                    streamingText = ""
                }
            }
        }
    }

    private func cancelRun() {
        agent.cancel()
        isRunning = false
        if !streamingText.isEmpty {
            messages.append(ChatMessage(role: .assistant, text: streamingText + " [cancelled]"))
            streamingText = ""
        }
    }
}

// MARK: - Configuration

/// Configuration for `AgentChatView`.
public struct AgentChatConfiguration {
    /// Show tool call timeline below the chat
    public var showToolCalls: Bool
    /// Show streaming text preview while the model is generating
    public var showStreamingPreview: Bool
    /// Use `runStreaming` instead of `run` for responses
    public var useStreaming: Bool
    /// Maximum height of the tool call timeline
    public var toolCallTimelineHeight: CGFloat
    /// Placeholder text for the input field
    public var inputPlaceholder: String

    public init(
        showToolCalls: Bool = true,
        showStreamingPreview: Bool = true,
        useStreaming: Bool = false,
        toolCallTimelineHeight: CGFloat = 150,
        inputPlaceholder: String = "Message the agent…"
    ) {
        self.showToolCalls = showToolCalls
        self.showStreamingPreview = showStreamingPreview
        self.useStreaming = useStreaming
        self.toolCallTimelineHeight = toolCallTimelineHeight
        self.inputPlaceholder = inputPlaceholder
    }

    public static let `default` = AgentChatConfiguration()
}

// MARK: - Chat Message Model

/// A chat message for display in the UI.
public struct ChatMessage: Identifiable {
    public let id = UUID()
    public let role: Role
    public var text: String
    public var isStreaming: Bool
    public var isError: Bool

    public enum Role {
        case user
        case assistant
    }

    public init(role: Role, text: String, isStreaming: Bool = false, isError: Bool = false) {
        self.role = role
        self.text = text
        self.isStreaming = isStreaming
        self.isError = isError
    }
}

// MARK: - Tool Call Event Model

/// A tool call event for the timeline view.
public struct ToolCallEvent: Identifiable {
    public let id = UUID()
    public let name: String
    public var status: ToolCallStatus
    public var result: String?

    public init(name: String, status: ToolCallStatus, result: String? = nil) {
        self.name = name
        self.status = status
        self.result = result
    }
}

public enum ToolCallStatus {
    case pending
    case running
    case done
    case error
}
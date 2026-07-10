import XCTest
import SwiftAgentKit
import SwiftAgentKitUI
@testable import SwiftAgentKitUI

final class ComponentViewTests: XCTestCase {

    // MARK: - MessageBubble

    func testMessageBubbleUserMessage() {
        let msg = ChatMessage(role: .user, text: "Hello")
        _ = MessageBubble(message: msg)
    }

    func testMessageBubbleAssistantMessage() {
        let msg = ChatMessage(role: .assistant, text: "Hi there")
        _ = MessageBubble(message: msg)
    }

    func testMessageBubbleErrorMessage() {
        let msg = ChatMessage(role: .assistant, text: "Error occurred", isError: true)
        XCTAssertTrue(msg.isError)
        _ = MessageBubble(message: msg)
    }

    func testMessageBubbleStreamingMessage() {
        let msg = ChatMessage(role: .assistant, text: "Loading...", isStreaming: true)
        XCTAssertTrue(msg.isStreaming)
        _ = MessageBubble(message: msg)
    }

    // MARK: - InputBar

    func testInputBarSendButtonDisabledWhenEmpty() {
        _ = InputBar(
            text: .constant(""),
            isRunning: false,
            onSend: {},
            onCancel: {}
        )
    }

    func testInputBarShowsCancelWhenRunning() {
        _ = InputBar(
            text: .constant("test"),
            isRunning: true,
            onSend: {},
            onCancel: {}
        )
    }

    func testInputBarWithText() {
        _ = InputBar(
            text: .constant("Hello world"),
            isRunning: false,
            onSend: {},
            onCancel: {}
        )
    }

    // MARK: - ToolCallTimeline

    func testToolCallTimelineWithMultipleEvents() {
        let events: [ToolCallEvent] = [
            ToolCallEvent(name: "search", status: .pending),
            ToolCallEvent(name: "calc", status: .done, result: "42"),
            ToolCallEvent(name: "write", status: .error, result: "Permission denied"),
        ]
        _ = ToolCallTimeline(events: events)
    }

    func testToolCallTimelineEmpty() {
        _ = ToolCallTimeline(events: [])
    }

    // MARK: - AgentChatTranscript (via public AgentChatView usage and @testable)

    func testAgentChatTranscriptToolCallEvents() {
        var transcript = AgentChatTranscript()
        transcript.startSubmittedQuery("Test")
        transcript.handleEvent(.toolCallsReceived([
            AgentToolCall(id: "c1", name: "search", parameters: [:]),
        ]))

        XCTAssertEqual(transcript.toolCallEvents.count, 1)
        XCTAssertEqual(transcript.toolCallEvents[0].name, "search")
        XCTAssertEqual(transcript.toolCallEvents[0].status, .pending)
    }

    func testAgentChatTranscriptToolCallProgression() {
        var transcript = AgentChatTranscript()
        transcript.startSubmittedQuery("Test")

        let call = AgentToolCall(id: "c1", name: "search", parameters: [:])

        transcript.handleEvent(.toolCallsReceived([call]))
        XCTAssertEqual(transcript.toolCallEvents[0].status, .pending)

        transcript.handleEvent(.toolExecutionStarted(call: call))
        XCTAssertEqual(transcript.toolCallEvents[0].status, .running)

        let result = AgentToolResult.success(
            toolCallId: "c1",
            toolName: "search",
            result: "Found 3 items"
        )
        transcript.handleEvent(.toolExecutionFinished(call: call, result: result))

        XCTAssertEqual(transcript.toolCallEvents[0].status, .done)
        XCTAssertEqual(transcript.toolCallEvents[0].result, "Found 3 items")
    }

    func testAgentChatTranscriptErrorResult() {
        var transcript = AgentChatTranscript()
        transcript.startSubmittedQuery("Test")

        let call = AgentToolCall(id: "c1", name: "search", parameters: [:])

        transcript.handleEvent(.toolCallsReceived([call]))
        transcript.handleEvent(.toolExecutionStarted(call: call))

        let errorResult = AgentToolResult.error(
            toolCallId: "c1",
            toolName: "search",
            message: "Permission denied"
        )
        transcript.handleEvent(.toolExecutionFinished(call: call, result: errorResult))

        XCTAssertEqual(transcript.toolCallEvents[0].status, .error)
        XCTAssertEqual(transcript.toolCallEvents[0].result, "Permission denied")
    }

    func testAgentChatTranscriptFailRun() {
        var transcript = AgentChatTranscript()
        transcript.startSubmittedQuery("test")

        transcript.failRun(AgentError.maxTurnsReached(6))

        XCTAssertEqual(transcript.messages.last?.isError, true)
        XCTAssertFalse(transcript.isRunning)
    }

    func testAgentChatTranscriptCancelRunWithStreamingText() {
        var transcript = AgentChatTranscript()
        transcript.startSubmittedQuery("test")
        transcript.handleEvent(.streamChunk("partial"))

        transcript.cancelRun()

        XCTAssertNotNil(transcript.messages.last?.text)
        XCTAssertTrue(transcript.messages.last?.text.contains("cancelled") ?? false)
        XCTAssertTrue(transcript.streamingText.isEmpty)
    }

    // MARK: - AgentChatConfiguration

    func testAgentChatConfigurationDefault() {
        let config = AgentChatConfiguration.default
        XCTAssertTrue(config.showToolCalls)
        XCTAssertTrue(config.showStreamingPreview)
        XCTAssertFalse(config.useStreaming)
    }

    func testAgentChatConfigurationCustom() {
        let config = AgentChatConfiguration(
            showToolCalls: false,
            showStreamingPreview: false,
            useStreaming: true,
            toolCallTimelineHeight: 200,
            inputPlaceholder: "Type here"
        )

        XCTAssertFalse(config.showToolCalls)
        XCTAssertFalse(config.showStreamingPreview)
        XCTAssertTrue(config.useStreaming)
        XCTAssertEqual(config.toolCallTimelineHeight, 200)
        XCTAssertEqual(config.inputPlaceholder, "Type here")
    }

    // MARK: - Model Identity / Equality

    func testChatMessageIdentity() {
        let a = ChatMessage(role: .user, text: "Hello")
        let b = ChatMessage(role: .user, text: "Hello")

        XCTAssertNotEqual(a.id, b.id)
    }

    func testToolCallStatusEquality() {
        XCTAssertNotEqual(ToolCallStatus.pending, ToolCallStatus.done)
        XCTAssertEqual(ToolCallStatus.done, ToolCallStatus.done)
    }
}
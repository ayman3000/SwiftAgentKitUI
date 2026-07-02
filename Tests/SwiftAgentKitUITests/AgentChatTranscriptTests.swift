import XCTest
import SwiftAgentKit
@testable import SwiftAgentKitUI

final class AgentChatTranscriptTests: XCTestCase {
    func testStartSubmittedQueryAddsUserMessageAndRunningState() {
        var transcript = AgentChatTranscript()

        transcript.startSubmittedQuery("Hello")

        XCTAssertEqual(transcript.messages.count, 1)
        XCTAssertEqual(transcript.messages.first?.role, .user)
        XCTAssertEqual(transcript.messages.first?.text, "Hello")
        XCTAssertTrue(transcript.isRunning)
        XCTAssertTrue(transcript.streamingText.isEmpty)
        XCTAssertTrue(transcript.toolCallEvents.isEmpty)
    }

    func testStartedEventDoesNotDuplicateAlreadySubmittedUserMessage() {
        var transcript = AgentChatTranscript()
        transcript.startSubmittedQuery("Hello")

        transcript.handleEvent(.started(query: "Hello"))

        XCTAssertEqual(transcript.messages.count, 1)
        XCTAssertEqual(transcript.messages.first?.text, "Hello")
    }

    func testRunStreamingChunksAreNotDuplicatedByAgentStreamEvents() {
        var transcript = AgentChatTranscript()
        transcript.startSubmittedQuery("Hello")

        transcript.handleEvent(.streamChunk("Hi"), ignoresStreamChunks: true)
        transcript.appendRunStreamingChunk("Hi")
        transcript.handleEvent(.streamChunk(" there"), ignoresStreamChunks: true)
        transcript.appendRunStreamingChunk(" there")
        transcript.finishRun()

        XCTAssertEqual(transcript.messages.count, 2)
        XCTAssertEqual(transcript.messages.last?.role, .assistant)
        XCTAssertEqual(transcript.messages.last?.text, "Hi there")
        XCTAssertFalse(transcript.isRunning)
        XCTAssertTrue(transcript.streamingText.isEmpty)
    }

    func testExternalStreamChunkEventsStillUpdateStreamingText() {
        var transcript = AgentChatTranscript()

        transcript.handleEvent(.started(query: "Hello"))
        transcript.handleEvent(.streamChunk("Hi"), ignoresStreamChunks: false)
        transcript.handleEvent(.streamChunk(" there"), ignoresStreamChunks: false)
        transcript.finishRun()

        XCTAssertEqual(transcript.messages.count, 2)
        XCTAssertEqual(transcript.messages.first?.role, .user)
        XCTAssertEqual(transcript.messages.last?.role, .assistant)
        XCTAssertEqual(transcript.messages.last?.text, "Hi there")
    }
}

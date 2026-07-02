import SwiftUI
import XCTest
import SwiftAgentKitUI

final class PublicComponentAPITests: XCTestCase {
    func testReadmeListedComponentsArePubliclyConstructible() {
        let message = ChatMessage(role: .assistant, text: "Hello")
        _ = MessageBubble(message: message)
        _ = ToolCallTimeline(events: [
            ToolCallEvent(name: "search", status: .pending),
        ])
        _ = InputBar(
            text: .constant(""),
            placeholder: "Ask anything",
            isRunning: false,
            onSend: {},
            onCancel: {}
        )
    }
}

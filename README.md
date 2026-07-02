# SwiftAgentKitUI

Ready-made SwiftUI views for AI agent apps. Built on [SwiftAgentKit](https://github.com/ayman3000/SwiftAgentKit).

> **SwiftAgentKit runs the agent loop. SwiftAgentKitUI gives you the chat UI.**

---

## What's included

| View | Description |
|---|---|
| `AgentChatView` | Full agent chat — message bubbles, input bar, send/cancel, streaming preview |
| `AgentEventView` | Real-time event timeline — every LLM call, tool call, retry, and finish event |
| `MessageBubble` | Individual message rendering (user/assistant, with error states) |
| `ToolCallTimeline` | Tool call status list — pending, running, done, error |
| `InputBar` | Text input with send/cancel button, multi-line support |

---

## Quick start

```swift
import SwiftUI
import SwiftAgentKit
import SwiftAgentKitUI
import LLMProviderKit
import LLMProviderKitOllama

struct ContentView: View {
    let agent = Agent(config: AgentConfig(
        provider: OllamaProvider(configuration: .local(model: "llama3.2")),
        systemPrompt: "You are a helpful assistant.",
        maxTurns: 6
    ))

    var body: some View {
        AgentChatView(agent: agent)
    }
}
```

That's it — a full agent chat with message bubbles, tool call timeline, and streaming support.

---

## Configuration

```swift
AgentChatView(
    agent: agent,
    configuration: AgentChatConfiguration(
        showToolCalls: true,           // tool call timeline below chat
        showStreamingPreview: true,     // live text preview while generating
        useStreaming: true,             // use runStreaming instead of run
        toolCallTimelineHeight: 200,    // max height of tool timeline
        inputPlaceholder: "Ask me anything…"
    )
)
```

---

## Event timeline (debug panel)

```swift
// Side-by-side: chat + event timeline
HStack {
    AgentChatView(agent: agent)
    AgentEventView(agent: agent)
        .frame(width: 300)
}
```

Shows every event: LLM calls, tool dispatch, tool results, planning, repair retries, history trimming, skill activation — with timestamps and color-coded icons.

---

## Example app

A standalone demo app should live in its own repository so it exercises the same integration path as real users: adding `SwiftAgentKitUI` from GitHub rather than referencing this checkout locally.

Recommended demo repository: [SwiftAgentKitUIDemo](https://github.com/ayman3000/SwiftAgentKitUIDemo)

The demo should depend only on GitHub package URLs:

- [SwiftAgentKitUI](https://github.com/ayman3000/SwiftAgentKitUI)
- [SwiftAgentKit](https://github.com/ayman3000/SwiftAgentKit)
- [LLMProviderKit](https://github.com/ayman3000/LLMProviderKit)

---

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ayman3000/SwiftAgentKitUI.git", from: "0.1.0-alpha.1"),
    .package(url: "https://github.com/ayman3000/SwiftAgentKit.git", from: "0.1.0-alpha.1"),
    .package(url: "https://github.com/ayman3000/LLMProviderKit.git", from: "0.1.0-alpha.1"),
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftAgentKitUI", package: "SwiftAgentKitUI"),
        .product(name: "SwiftAgentKit", package: "SwiftAgentKit"),
        .product(name: "LLMProviderKit", package: "LLMProviderKit"),
        .product(name: "LLMProviderKitOllama", package: "LLMProviderKit"),
    ])
]
```

Or in Xcode: **File ▸ Add Package Dependencies** → `https://github.com/ayman3000/SwiftAgentKitUI`

---

## Requirements

- Swift 5.9+
- macOS 13+ / iOS 16+
- [SwiftAgentKit](https://github.com/ayman3000/SwiftAgentKit)
- [LLMProviderKit](https://github.com/ayman3000/LLMProviderKit)

---

## License

MIT

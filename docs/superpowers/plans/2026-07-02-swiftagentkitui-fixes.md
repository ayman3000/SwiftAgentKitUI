# SwiftAgentKitUI Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the reviewed package issues: streaming duplication, observer re-registration, ignored placeholder configuration, and README/API mismatch.

**Architecture:** Move chat transcript mutations into a small internal `AgentChatTranscript` value type that can be unit tested without rendering SwiftUI. Keep `AgentChatView` as the coordinator between SwiftUI, `Agent`, and the transcript state.

**Tech Stack:** SwiftPM, SwiftUI, XCTest, SwiftAgentKit.

---

### Task 1: Add Tests

**Files:**
- Modify: `Package.swift`
- Create: `Tests/SwiftAgentKitUITests/AgentChatTranscriptTests.swift`
- Create: `Tests/SwiftAgentKitUITests/PublicComponentAPITests.swift`

- [x] Add an XCTest test target named `SwiftAgentKitUITests`.
- [x] Add transcript tests covering submitted query state, ignored agent stream chunks during `runStreaming`, and external stream chunk handling.
- [x] Add public API compile tests for `MessageBubble`, `ToolCallTimeline`, and `InputBar`.
- [x] Run `swift test` and verify the tests fail before implementation.

### Task 2: Fix Chat State and Streaming

**Files:**
- Create: `Sources/SwiftAgentKitUI/AgentChatTranscript.swift`
- Modify: `Sources/SwiftAgentKitUI/AgentChatView.swift`

- [x] Add `AgentChatTranscript` with `startSubmittedQuery`, `handleEvent`, `appendRunStreamingChunk`, `finishRun`, `failRun`, and `cancelRun`.
- [x] Have `AgentChatView` append the user message when sending, because no-tool streaming does not emit `.started`.
- [x] Ignore agent `.streamChunk` events only while the view is consuming chunks returned by `runStreaming`, preventing duplicate streamed text.
- [x] Guard observer setup so repeated `onAppear` calls do not register duplicate observers for the same view state.

### Task 3: Fix Configuration and Public API

**Files:**
- Modify: `Sources/SwiftAgentKitUI/InputBar.swift`
- Modify: `Sources/SwiftAgentKitUI/MessageBubble.swift`
- Modify: `Sources/SwiftAgentKitUI/ToolCallTimeline.swift`
- Modify: `Sources/SwiftAgentKitUI/AgentChatView.swift`

- [x] Add a `placeholder` property to `InputBar` and pass `AgentChatConfiguration.inputPlaceholder`.
- [x] Make README-listed component views public with explicit public initializers and public `body` properties.
- [x] Keep helper rows internal unless they are documented as public API.

### Task 4: Verify

**Files:**
- All changed files.

- [x] Run `swift test`.
- [x] Run `swift build`.
- [x] Inspect `git diff --check`.
- [x] Inspect `git status --short`.

# Prompt: Create SwiftAgentKitUI Client Demo Project

Use this prompt later to create the standalone client example project.

```text
Create a standalone GitHub-ready SwiftUI demo app for SwiftAgentKitUI.

Repository name:
https://github.com/ayman3000/SwiftAgentKitUIDemo

Requirements:
- Create a real macOS SwiftUI app example that demonstrates SwiftAgentKitUI.
- Use GitHub package URLs only. Do not use local package paths.
- Add dependencies from:
  - https://github.com/ayman3000/SwiftAgentKitUI.git
  - https://github.com/ayman3000/SwiftAgentKit.git
  - https://github.com/ayman3000/LLMProviderKit.git
- Use SwiftPM or an Xcode project generated from SwiftPM as the source of truth.
- The first screen should be the actual chat UI, not a landing page.
- Use AgentChatView as the main experience.
- Include AgentEventView in a secondary pane or inspector-style area when practical.
- Prefer an Ollama-based provider example so the app can run without cloud API keys.
- Keep all dependency links as GitHub links in Package.swift and documentation.
- Include a README with setup steps, requirements, and troubleshooting notes.
- Verify with swift build and, if an Xcode project is generated, xcodebuild.
- Do not vendor or copy SwiftAgentKitUI source into the demo repository.
```

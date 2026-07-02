// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftAgentKitUI",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(name: "SwiftAgentKitUI", targets: ["SwiftAgentKitUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ayman3000/SwiftAgentKit.git", from: "0.1.0-alpha.1"),
        .package(url: "https://github.com/ayman3000/LLMProviderKit.git", from: "0.1.0-alpha.1"),
    ],
    targets: [
        .target(
            name: "SwiftAgentKitUI",
            dependencies: [
                .product(name: "SwiftAgentKit", package: "SwiftAgentKit"),
                .product(name: "LLMProviderKit", package: "LLMProviderKit"),
            ]
        ),
        .testTarget(
            name: "SwiftAgentKitUITests",
            dependencies: [
                "SwiftAgentKitUI",
                .product(name: "SwiftAgentKit", package: "SwiftAgentKit"),
            ]
        ),
    ]
)

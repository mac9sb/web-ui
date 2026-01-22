// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "web-ui",
    platforms: [
        .macOS(.v15), .tvOS(.v13), .iOS(.v16), .watchOS(.v6), .visionOS(.v2),
    ],
    products: [
        .library(name: "WebUI", targets: ["WebUI"]),
        .library(name: "WebUITypst", targets: ["WebUITypst"]),
        .library(name: "WebUIMarkdown", targets: ["WebUIMarkdown"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-markdown", from: "0.6.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3"),
        .package(url: "https://github.com/swiftlang/swift-testing", from: "0.11.0"),
    ],
    targets: [
        .target(
            name: "WebUI",
        ),
        .target(
            name: "WebUITypst",
        ),
        .target(
            name: "WebUIMarkdown",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown")
            ]
        ),
        .testTarget(
            name: "WebUITests",
            dependencies: [
                "WebUI",
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
        .testTarget(
            name: "WebUIMarkdownTests",
            dependencies: [
                "WebUIMarkdown",
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AxiomWeb",
    platforms: [
        .macOS(.v15), .iOS(.v16), .tvOS(.v13), .watchOS(.v10), .visionOS(.v1),
    ],
    products: [
        .library(name: "AxiomWeb", targets: ["AxiomWeb"]),
        .library(name: "AxiomWebUI", targets: ["AxiomWebUI"]),
        .library(name: "AxiomWebStyle", targets: ["AxiomWebStyle"]),
        .library(name: "AxiomWebRuntime", targets: ["AxiomWebRuntime"]),
        .library(name: "AxiomWebRender", targets: ["AxiomWebRender"]),
        .library(name: "AxiomWebMarkdown", targets: ["AxiomWebMarkdown"]),
        .library(name: "AxiomWebUIComponents", targets: ["AxiomWebUIComponents"]),
        .library(name: "AxiomWebTesting", targets: ["AxiomWebTesting"]),
        .library(name: "AxiomWebServer", targets: ["AxiomWebServer"]),
        .library(name: "AxiomWebCodegen", targets: ["AxiomWebCodegen"]),
        .library(name: "AxiomWebCLI", targets: ["AxiomWebCLI"]),
        .library(name: "AxiomWebI18n", targets: ["AxiomWebI18n"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-markdown", from: "0.6.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-http-types", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-metrics", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-distributed-tracing", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AxiomWeb",
            dependencies: [
                "AxiomWebUI",
                "AxiomWebStyle",
                "AxiomWebRuntime",
                "AxiomWebRender",
                "AxiomWebMarkdown",
                "AxiomWebUIComponents",
                "AxiomWebTesting",
                "AxiomWebServer",
                "AxiomWebCodegen",
                "AxiomWebCLI",
                "AxiomWebI18n",
            ]
        ),
        .target(
            name: "AxiomWebUI",
            dependencies: ["AxiomWebI18n"]
        ),
        .target(
            name: "AxiomWebStyle",
            dependencies: ["AxiomWebUI"]
        ),
        .target(
            name: "AxiomWebRuntime",
            dependencies: [
                "AxiomWebUI",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
            ]
        ),
        .target(
            name: "AxiomWebRender",
            dependencies: [
                "AxiomWebUI",
                "AxiomWebStyle",
                "AxiomWebRuntime",
                "AxiomWebI18n",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
            ]
        ),
        .target(
            name: "AxiomWebMarkdown",
            dependencies: [
                "AxiomWebUI",
                "AxiomWebStyle",
                "AxiomWebI18n",
                .product(name: "Markdown", package: "swift-markdown"),
            ]
        ),
        .target(
            name: "AxiomWebUIComponents",
            dependencies: [
                "AxiomWebUI",
                "AxiomWebStyle",
                "AxiomWebRuntime",
                "AxiomWebI18n",
            ]
        ),
        .target(
            name: "AxiomWebTesting",
            dependencies: [
                "AxiomWebRender",
                "AxiomWebUI",
            ]
        ),
        .target(
            name: "AxiomWebServer",
            dependencies: [
                "AxiomWebUI",
                "AxiomWebRender",
                "AxiomWebI18n",
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "Tracing", package: "swift-distributed-tracing"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
            ]
        ),
        .target(name: "AxiomWebCodegen"),
        .target(
            name: "AxiomWebCLI",
            dependencies: [
                "AxiomWebServer",
                "AxiomWebRender",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(name: "AxiomWebI18n"),
        .testTarget(
            name: "AxiomWebTests",
            dependencies: [
                "AxiomWebUI",
                "AxiomWebStyle",
                "AxiomWebRuntime",
                "AxiomWebRender",
                "AxiomWebServer",
                "AxiomWebCodegen",
                "AxiomWebI18n",
                "AxiomWebTesting",
                "AxiomWebMarkdown",
                "AxiomWebUIComponents",
            ]
        ),
    ]
)

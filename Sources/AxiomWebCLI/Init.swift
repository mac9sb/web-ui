import Foundation
import ArgumentParser

public enum AxiomWebProjectType: String, Sendable, ExpressibleByArgument {
    case staticSite = "static"
    case server = "server"

    public init?(argument: String) {
        switch argument.lowercased() {
        case Self.staticSite.rawValue:
            self = .staticSite
        case Self.server.rawValue, "serevr":
            self = .server
        default:
            return nil
        }
    }

    public static var allValueStrings: [String] {
        [Self.staticSite.rawValue, Self.server.rawValue]
    }
}

public struct AxiomWebProjectInitConfiguration: Sendable, Equatable {
    public var projectDirectory: URL
    public var projectType: AxiomWebProjectType
    public var agentsFilePath: String?
    public var overwriteExisting: Bool

    public init(
        projectDirectory: URL = URL(filePath: "."),
        projectType: AxiomWebProjectType = .staticSite,
        agentsFilePath: String? = "AGENTS.md",
        overwriteExisting: Bool = false
    ) {
        self.projectDirectory = projectDirectory
        self.projectType = projectType
        self.agentsFilePath = agentsFilePath
        self.overwriteExisting = overwriteExisting
    }
}

public struct AxiomWebProjectInitReport: Sendable, Equatable {
    public var projectDirectory: String
    public var createdDirectories: [String]
    public var createdFiles: [String]
    public var overwrittenFiles: [String]

    public init(
        projectDirectory: String,
        createdDirectories: [String],
        createdFiles: [String],
        overwrittenFiles: [String]
    ) {
        self.projectDirectory = projectDirectory
        self.createdDirectories = createdDirectories
        self.createdFiles = createdFiles
        self.overwrittenFiles = overwrittenFiles
    }
}

public enum AxiomWebProjectInitError: Error, CustomStringConvertible {
    case existingFile(path: String)
    case invalidAgentsPath

    public var description: String {
        switch self {
        case .existingFile(let path):
            return "File already exists: \(path). Re-run with --force to overwrite."
        case .invalidAgentsPath:
            return "The agents file path cannot be empty."
        }
    }
}

public struct AxiomWebInitCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Create a new AxiomWeb project scaffold",
        aliases: ["axiomweb-init"]
    )

    @Argument(help: "Project directory to initialize")
    public var directory: String = "."

    @Option(help: "Project type: static or server")
    public var type: AxiomWebProjectType = .staticSite

    @Option(help: "Path for generated agent guidance file (relative to project directory unless absolute)")
    public var agentsFile: String = "AGENTS.md"

    @Flag(help: "Skip generating the agent guidance file")
    public var skipAgentsFile: Bool = false

    @Flag(name: .shortAndLong, help: "Overwrite existing scaffold files")
    public var force: Bool = false

    public init() {}

    public mutating func run() throws {
        let report = try AxiomWebCLI.initializeProject(
            configuration: .init(
                projectDirectory: URL(filePath: directory),
                projectType: type,
                agentsFilePath: skipAgentsFile ? nil : agentsFile,
                overwriteExisting: force
            )
        )

        print("Initialized AxiomWeb project at \(report.projectDirectory)")
        if !report.createdDirectories.isEmpty {
            print("Created directories: \(report.createdDirectories.joined(separator: ", "))")
        }
        if !report.createdFiles.isEmpty {
            print("Created files: \(report.createdFiles.joined(separator: ", "))")
        }
        if !report.overwrittenFiles.isEmpty {
            print("Overwritten files: \(report.overwrittenFiles.joined(separator: ", "))")
        }
    }
}

public extension AxiomWebCLI {
    static func initializeProject(
        configuration: AxiomWebProjectInitConfiguration = .init()
    ) throws -> AxiomWebProjectInitReport {
        let fileManager = FileManager.default
        let root = configuration.projectDirectory.standardizedFileURL
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)

        var createdDirectories: [String] = []
        var createdFiles: [String] = []
        var overwrittenFiles: [String] = []

        var directories = [
            "Routes/pages",
            "Components",
            "Assets",
        ]
        if configuration.projectType == .server {
            directories.append("Routes/api")
            directories.append("Routes/ws")
        }

        for directory in directories {
            let path = root.appending(path: directory)
            if !fileManager.fileExists(atPath: path.path()) {
                try fileManager.createDirectory(at: path, withIntermediateDirectories: true)
                createdDirectories.append(directory)
            }
        }

        let indexPath = root.appending(path: "Routes/pages/index.swift")
        let indexContents = AxiomWebProjectTemplate.indexPage
        try writeScaffoldFile(
            at: indexPath,
            contents: indexContents,
            root: root,
            overwrite: configuration.overwriteExisting,
            created: &createdFiles,
            overwritten: &overwrittenFiles
        )

        let componentPath = root.appending(path: "Components/SiteHeader.swift")
        try writeScaffoldFile(
            at: componentPath,
            contents: AxiomWebProjectTemplate.siteHeaderComponent,
            root: root,
            overwrite: configuration.overwriteExisting,
            created: &createdFiles,
            overwritten: &overwrittenFiles
        )

        if configuration.projectType == .server {
            let apiPath = root.appending(path: "Routes/api/hello.swift")
            try writeScaffoldFile(
                at: apiPath,
                contents: AxiomWebProjectTemplate.helloAPIRoute,
                root: root,
                overwrite: configuration.overwriteExisting,
                created: &createdFiles,
                overwritten: &overwrittenFiles
            )

            let websocketPath = root.appending(path: "Routes/ws/echo.swift")
            try writeScaffoldFile(
                at: websocketPath,
                contents: AxiomWebProjectTemplate.echoWebSocketRoute,
                root: root,
                overwrite: configuration.overwriteExisting,
                created: &createdFiles,
                overwritten: &overwrittenFiles
            )
        }

        let assetsKeepPath = root.appending(path: "Assets/.keep")
        try writeScaffoldFile(
            at: assetsKeepPath,
            contents: "",
            root: root,
            overwrite: configuration.overwriteExisting,
            created: &createdFiles,
            overwritten: &overwrittenFiles
        )

        if let agentsFilePath = configuration.agentsFilePath {
            let trimmed = agentsFilePath.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw AxiomWebProjectInitError.invalidAgentsPath
            }
            let agentsURL = resolvePath(trimmed, relativeTo: root)
            try writeScaffoldFile(
                at: agentsURL,
                contents: AxiomWebProjectTemplate.agentsFile,
                root: root,
                overwrite: configuration.overwriteExisting,
                created: &createdFiles,
                overwritten: &overwrittenFiles
            )
        }

        return AxiomWebProjectInitReport(
            projectDirectory: root.path(),
            createdDirectories: createdDirectories.sorted(),
            createdFiles: createdFiles.sorted(),
            overwrittenFiles: overwrittenFiles.sorted()
        )
    }
}

private func writeScaffoldFile(
    at url: URL,
    contents: String,
    root: URL,
    overwrite: Bool,
    created: inout [String],
    overwritten: inout [String]
) throws {
    let fileManager = FileManager.default
    let exists = fileManager.fileExists(atPath: url.path())
    if exists && !overwrite {
        throw AxiomWebProjectInitError.existingFile(path: relativePath(for: url, root: root))
    }

    try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try Data(contents.utf8).write(to: url)

    let relative = relativePath(for: url, root: root)
    if exists {
        overwritten.append(relative)
    } else {
        created.append(relative)
    }
}

private func resolvePath(_ path: String, relativeTo root: URL) -> URL {
    if path.hasPrefix("/") {
        return URL(filePath: path)
    }
    return root.appending(path: path)
}

private func relativePath(for url: URL, root: URL) -> String {
    let rootPath = root.path().hasSuffix("/") ? root.path() : root.path() + "/"
    let fullPath = url.path()
    if fullPath.hasPrefix(rootPath) {
        return String(fullPath.dropFirst(rootPath.count))
    }
    return fullPath
}

private enum AxiomWebProjectTemplate {
    static let indexPage = """
import AxiomWebUI

struct IndexPage: Document {
    var metadata: Metadata {
        Metadata(
            title: "AxiomWeb App",
            description: "Welcome to your new AxiomWeb project."
        )
    }

    var path: String { "/" }

    var body: some Markup {
        Main {
            SiteHeader(title: "Welcome to AxiomWeb")
            Paragraph("Edit Routes/pages/index.swift to start building.")
        }
    }
}
"""

    static let siteHeaderComponent = """
import AxiomWebUI

public struct SiteHeader: Element {
    private let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some Markup {
        Header {
            Heading(.h1, title)
        }
    }
}
"""

    static let helloAPIRoute = """
import AxiomWebServer

public struct HelloResponse: Codable, Sendable {
    public let message: String
}

public func registerHelloAPI(on routes: inout RouteOverrides) {
    routes.api(from: "hello.swift") { (_: EmptyAPIRequest, _) in
        APIResponse(body: HelloResponse(message: "Hello from AxiomWeb server"))
    }
}
"""

    static let echoWebSocketRoute = """
import AxiomWebServer

public func registerEchoWebSocket(on routes: inout RouteOverrides) {
    routes.websocket(from: "echo.swift") { message, _ in
        switch message.kind {
        case .text, .binary:
            return message
        case .ping:
            return WebSocketMessage(kind: .pong, data: message.data)
        case .continuation, .pong, .connectionClose:
            return nil
        }
    }
}
"""

    static let agentsFile = """
# AGENTS.md

## Axiom Project Rules

1. Keep authoring SwiftUI-like and declarative.
- Prefer typed elements and modifiers.
- Avoid raw HTML, CSS, and JavaScript strings for standard use cases.

2. Prefer typed APIs over escape hatches.
- Use typed tags (for example `Section`, `Dialog`, `Button`) instead of `Node("tag")` when available.
- Use semantic layout helpers (`.flex(...)`, `.grid(...)`) and `gap` instead of manual row/column gap APIs.

3. Keep components native-first.
- Prefer native web platform features (`details`, `dialog`, `popover`, semantic controls).
- Add JavaScript only when native behavior is insufficient.

4. Keep metadata and routing typed.
- Use typed metadata and structured data APIs.
- Follow route conventions in `Routes/pages` and `Routes/api`.

5. Keep tests first-class.
- Use Swift Testing (`import Testing`) for framework tests.
- Add or update tests alongside behavior changes.

6. Dependency policy.
- Check approved sources first:
  - Apple Collection
  - Swift.org Collection
  - SSWG Collection
  - Swift Server Community
- Ask permission before introducing dependencies outside those sources.
"""
}

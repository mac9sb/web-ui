import ArgumentParser
import Foundation
import Noora

struct RunCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "run",
        abstract: "Build and serve the static site"
    )

    @Option(name: [.long, .customShort("d")], help: "Project directory (default: current directory)")
    var path: String = "."

    @Option(name: .shortAndLong, help: "Port to serve on")
    var port: Int = 8000

    func run() throws {
        let projectDir = (path as NSString).expandingTildeInPath
        let absPath = (projectDir as NSString).standardizingPath
        let outputDir = (absPath as NSString).appendingPathComponent(".output")

        guard FileManager.default.fileExists(atPath: absPath) else {
            Noora().error("Directory does not exist: \(absPath)")
            throw RunError.projectNotFound
        }

        let packagePath = (absPath as NSString).appendingPathComponent("Package.swift")
        guard FileManager.default.fileExists(atPath: packagePath) else {
            Noora().error("No Package.swift in \(absPath)")
            throw RunError.notAWebUIPackage
        }

        Noora().info("Building in \(absPath) ...")

        let buildProcess = Process()
        buildProcess.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        buildProcess.arguments = ["swift", "run", "--package-path", absPath]
        buildProcess.currentDirectoryURL = URL(fileURLWithPath: absPath)
        buildProcess.standardOutput = FileHandle.standardOutput
        buildProcess.standardError = FileHandle.standardError

        try buildProcess.run()
        buildProcess.waitUntilExit()

        guard buildProcess.terminationStatus == 0 else {
            Noora().error("Build failed")
            throw RunError.buildFailed
        }

        Noora().success(.alert("Build complete", takeaways: ["Serving .output on http://127.0.0.1:\(port)"]))
        Noora().info("Press Ctrl+C to stop")

        try runAsyncAndWait {
            try await runStaticServer(directory: outputDir, port: port)
        }
    }
}

enum RunError: Error {
    case projectNotFound
    case notAWebUIPackage
    case buildFailed
}

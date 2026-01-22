import ArgumentParser
import Foundation
import Noora

struct BuildCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build the static site"
    )

    @Option(name: .shortAndLong, help: "Project directory (default: current directory)")
    var path: String = "."

    func run() throws {
        let projectDir = (path as NSString).expandingTildeInPath
        let absPath = (projectDir as NSString).standardizingPath

        guard FileManager.default.fileExists(atPath: absPath) else {
            Noora().error("Directory does not exist: \(absPath)")
            throw BuildError.projectNotFound
        }

        let packagePath = (absPath as NSString).appendingPathComponent("Package.swift")
        guard FileManager.default.fileExists(atPath: packagePath) else {
            Noora().error("No Package.swift in \(absPath)")
            throw BuildError.notAWebUIPackage
        }

        Noora().info("Building in \(absPath) ...")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", "run", "--package-path", absPath]
        process.currentDirectoryURL = URL(fileURLWithPath: absPath)
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            Noora().error("Build failed")
            throw BuildError.buildFailed
        }

        Noora().success(.alert("Build complete", takeaways: ["Output: \(absPath)/.output"]))
    }
}

enum BuildError: Error {
    case projectNotFound
    case notAWebUIPackage
    case buildFailed
}

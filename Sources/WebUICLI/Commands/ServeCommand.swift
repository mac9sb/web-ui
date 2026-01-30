import ArgumentParser
import Foundation
import Noora

struct ServeCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "serve",
        abstract: "Serve an already-built site"
    )

    @Option(name: [.long, .customShort("d")], help: "Directory to serve (default: .output)")
    var path: String = ".output"

    @Option(name: .shortAndLong, help: "Port to listen on")
    var port: Int = 8000

    func run() throws {
        let absPath = path.expandedStandardizedPath

        guard FileManager.default.fileExists(atPath: absPath) else {
            Noora().error("Directory does not exist: \(absPath)")
            throw ServeError.directoryNotFound
        }

        Noora().info("Serving \(absPath) on http://127.0.0.1:\(port)")
        Noora().info("Press Ctrl+C to stop")

        try runAsyncAndWait {
            try await runStaticServer(directory: absPath, port: port)
        }
    }
}

enum ServeError: Error {
    case directoryNotFound
}

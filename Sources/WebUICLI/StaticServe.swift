import Foundation
import Hummingbird
import Logging

private final class SendableBox<T: Sendable>: @unchecked Sendable {
    var value: T
    init(_ value: T) { self.value = value }
}

/// Runs an async closure from a synchronous context, blocking until it completes.
func runAsyncAndWait(_ body: @escaping @Sendable () async throws -> Void) throws {
    let sem = DispatchSemaphore(value: 0)
    let errorBox = SendableBox<Error?>(nil)
    Task {
        do {
            try await body()
        } catch {
            errorBox.value = error
        }
        sem.signal()
    }
    sem.wait()
    if let e = errorBox.value { throw e }
}

/// Runs a Hummingbird static file server for the given directory until interrupted.
func runStaticServer(directory: String, port: Int) async throws {
    let logger = Logger(label: "web-ui.serve")
    let router = Router(context: BasicRequestContext.self)
    router.addMiddleware {
        FileMiddleware(directory, searchForIndexHtml: true)
    }

    var app = Application(
        router: router,
        configuration: .init(address: .hostname("127.0.0.1", port: port))
    )
    app.logger = logger

    try await app.runService()
}

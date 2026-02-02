import Foundation

public struct TimeoutConfiguration: Sendable {
    public var duration: Duration
    public var operationDescription: String

    public init(
        duration: Duration,
        operationDescription: String = "operation"
    ) {
        self.duration = duration
        self.operationDescription = operationDescription
    }
}

public enum Timeout {
    public static func withTimeout<T: Sendable>(
        _ configuration: TimeoutConfiguration,
        operation: @Sendable @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                let timeLimit = configuration.duration
                try await Task.sleep(for: timeLimit)
                throw BrowserError.timeout(
                    operation: configuration.operationDescription,
                    seconds: timeLimit.timeInterval
                )
            }

            let result = try await group.next()
            group.cancelAll()
            if let result {
                return result
            }
            throw BrowserError.internalInconsistency(message: "Timeout task group finished without a result.")
        }
    }
}

private extension Duration {
    var timeInterval: TimeInterval {
        let components = self.components
        let seconds = Double(components.seconds)
        let attoseconds = Double(components.attoseconds) / 1_000_000_000_000_000_000.0
        return seconds + attoseconds
    }
}

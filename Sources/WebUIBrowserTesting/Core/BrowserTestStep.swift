import Foundation

/// A single executable step in a browser test flow.
public protocol BrowserTestStep: Sendable {
    /// Executes the step against a shared test context.
    /// - Parameter context: The shared test context.
    @MainActor func run(in context: BrowserTestContext) async throws
}

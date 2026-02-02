import Foundation

/// A reusable plan of browser test steps.
public struct BrowserTestPlan: Sendable {
    public let name: String
    public let steps: [BrowserTestStep]

    public init(_ name: String, @BrowserTestBuilder _ build: BrowserTestContent) {
        self.name = name
        self.steps = build()
    }

    /// Executes the test plan with a fresh browser and page.
    @MainActor public func run(
        configuration: BrowserConfiguration = .default,
        wait: BrowserTestWaitOptions = .default,
        metadata: [String: String] = [:]
    ) async throws {
        let browser = Browser(configuration: configuration)
        try await browser.launch()
        defer { Task { try? await browser.close() } }

        let page = try await browser.newPage()
        let context = BrowserTestContext(
            browser: browser,
            page: page,
            wait: wait,
            metadata: metadata
        )
        try await run(in: context)
    }

    /// Executes the test plan using an existing context.
    @MainActor public func run(in context: BrowserTestContext) async throws {
        for step in steps {
            try await step.run(in: context)
        }
    }
}

public func BrowserTest(_ name: String, @BrowserTestBuilder _ build: BrowserTestContent) -> BrowserTestPlan {
    BrowserTestPlan(name, build)
}

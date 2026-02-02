import Foundation

/// Shared context passed through browser test steps.
public struct BrowserTestContext: Sendable {
    public let browser: Browser
    public let page: Page
    public var wait: BrowserTestWaitOptions
    public var metadata: [String: String]
    public var scope: Selector?

    public init(
        browser: Browser,
        page: Page,
        wait: BrowserTestWaitOptions = .default,
        metadata: [String: String] = [:],
        scope: Selector? = nil
    ) {
        self.browser = browser
        self.page = page
        self.wait = wait
        self.metadata = metadata
        self.scope = scope
    }

    /// Returns a new context scoped to a selector.
    public func scoped(to selector: Selector) -> BrowserTestContext {
        var updated = self
        if let scope {
            updated.scope = .scoped(root: scope, child: selector)
        } else {
            updated.scope = selector
        }
        return updated
    }

    /// Resolves a selector against the current scope.
    public func resolve(_ selector: Selector) -> Selector {
        if let scope {
            return .scoped(root: scope, child: selector)
        }
        return selector
    }

    /// Finds the first matching element without waiting.
    public func find(_ selector: Selector) async -> ElementHandle? {
        await page.querySelector(resolve(selector))
    }

    /// Returns all matching elements without waiting.
    public func all(_ selector: Selector) async -> [ElementHandle] {
        await page.querySelectorAll(resolve(selector))
    }

    /// Waits for a matching element to exist and returns it.
    public func require(
        _ selector: Selector,
        timeout: Duration? = nil
    ) async throws -> ElementHandle {
        let resolved = resolve(selector)
        let timeout = timeout ?? wait.elementTimeout
        let timeoutConfig = TimeoutConfiguration(
            duration: timeout,
            operationDescription: "waitForElement(\(resolved.description))"
        )

        return try await Timeout.withTimeout(timeoutConfig) {
            while true {
                if let element = await page.querySelector(resolved) {
                    return element
                }
                try await Task.sleep(for: wait.pollingInterval)
            }
        }
    }

    /// Waits for a matching element to be visible.
    public func waitForVisible(
        _ selector: Selector,
        timeout: Duration? = nil
    ) async throws -> ElementHandle {
        let element = try await require(selector, timeout: timeout)
        let timeout = timeout ?? wait.elementTimeout
        try await element.waitForVisible(timeout: timeout, pollingInterval: wait.pollingInterval)
        return element
    }
}

/// Default wait timings for browser test actions.
public struct BrowserTestWaitOptions: Sendable {
    /// Default timeout for waiting on element visibility or existence.
    public var elementTimeout: Duration
    /// Polling interval used for repeated checks.
    public var pollingInterval: Duration
    /// Default navigation timeout.
    public var navigationTimeout: Duration

    public init(
        elementTimeout: Duration = .seconds(5),
        pollingInterval: Duration = .milliseconds(100),
        navigationTimeout: Duration = .seconds(30)
    ) {
        self.elementTimeout = elementTimeout
        self.pollingInterval = pollingInterval
        self.navigationTimeout = navigationTimeout
    }

    public static let `default` = BrowserTestWaitOptions()
}

import Foundation

// MARK: - Navigation

public struct NavigateStep: BrowserTestStep {
    public let url: String
    public let waitUntil: WaitStrategy
    public let timeout: Duration?

    public init(to url: String, waitUntil: WaitStrategy = .load, timeout: Duration? = nil) {
        self.url = url
        self.waitUntil = waitUntil
        self.timeout = timeout
    }

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let navigationTimeout = timeout ?? context.wait.navigationTimeout
        let options = NavigationOptions(waitUntil: waitUntil, timeout: navigationTimeout)
        try await context.page.goto(url, options: options)
    }
}

public func Navigate(to url: String, waitUntil: WaitStrategy = .load, timeout: Duration? = nil) -> BrowserTestStep {
    NavigateStep(to: url, waitUntil: waitUntil, timeout: timeout)
}

// MARK: - Scoping

public struct ScopeStep: BrowserTestStep {
    public let selector: Selector
    public let steps: [BrowserTestStep]

    public init(selector: Selector, @BrowserTestBuilder _ build: BrowserTestContent) {
        self.selector = selector
        self.steps = build()
    }

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let scopedContext = context.scoped(to: selector)
        for step in steps {
            try await step.run(in: scopedContext)
        }
    }
}

public func In(_ name: String, role: Role = .region, @BrowserTestBuilder _ build: BrowserTestContent) -> BrowserTestStep {
    ScopeStep(selector: .role(role, name: name), build)
}

public func In(role: Role, name: String? = nil, @BrowserTestBuilder _ build: BrowserTestContent) -> BrowserTestStep {
    ScopeStep(selector: .role(role, name: name), build)
}

public func In(_ selector: Selector, @BrowserTestBuilder _ build: BrowserTestContent) -> BrowserTestStep {
    ScopeStep(selector: selector, build)
}

// MARK: - Assertions / Grouping

public struct AssertViewStep: BrowserTestStep {
    public let steps: [BrowserTestStep]

    public init(@BrowserTestBuilder _ build: BrowserTestContent) {
        self.steps = build()
    }

    @MainActor public func run(in context: BrowserTestContext) async throws {
        for step in steps {
            try await step.run(in: context)
        }
    }
}

public func AssertView(@BrowserTestBuilder _ build: BrowserTestContent) -> BrowserTestStep {
    AssertViewStep(build)
}

// MARK: - Semantic Elements

public struct SemanticElement: BrowserTestStep {
    public let selector: Selector
    public let timeout: Duration?

    public init(selector: Selector, timeout: Duration? = nil) {
        self.selector = selector
        self.timeout = timeout
    }

    @MainActor public func run(in context: BrowserTestContext) async throws {
        _ = try await context.waitForVisible(selector, timeout: timeout)
    }

    public func fill(_ text: String) -> BrowserTestStep {
        FillStep(selector: selector, text: text, timeout: timeout)
    }

    public func type(_ text: String, delay: Duration? = nil) -> BrowserTestStep {
        TypeStep(selector: selector, text: text, timeout: timeout, delay: delay)
    }

    public func press(_ key: String) -> BrowserTestStep {
        PressStep(selector: selector, key: key, timeout: timeout)
    }

    public func clear() -> BrowserTestStep {
        ClearStep(selector: selector, timeout: timeout)
    }

    public func check() -> BrowserTestStep {
        CheckStep(selector: selector, timeout: timeout)
    }

    public func uncheck() -> BrowserTestStep {
        UncheckStep(selector: selector, timeout: timeout)
    }

    public func select(_ value: String) -> BrowserTestStep {
        SelectOptionStep(selector: selector, value: value, timeout: timeout)
    }

    public func hover() -> BrowserTestStep {
        HoverStep(selector: selector, timeout: timeout)
    }

    public func focus() -> BrowserTestStep {
        FocusStep(selector: selector, timeout: timeout)
    }

    public func blur() -> BrowserTestStep {
        BlurStep(selector: selector, timeout: timeout)
    }

    public func tap() -> BrowserTestStep {
        TapStep(selector: selector, timeout: timeout)
    }
}

// MARK: - Element Actions

public struct TapStep: BrowserTestStep {
    public let selector: Selector
    public let timeout: Duration?

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let element = try await context.waitForVisible(selector, timeout: timeout)
        try await element.click()
    }
}

public struct FillStep: BrowserTestStep {
    public let selector: Selector
    public let text: String
    public let timeout: Duration?

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let element = try await context.waitForVisible(selector, timeout: timeout)
        try await element.fill(text)
    }
}

public struct TypeStep: BrowserTestStep {
    public let selector: Selector
    public let text: String
    public let timeout: Duration?
    public let delay: Duration?

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let element = try await context.waitForVisible(selector, timeout: timeout)
        let options = TypeOptions(delay: delay)
        try await element.type(text, options: options)
    }
}

public struct PressStep: BrowserTestStep {
    public let selector: Selector
    public let key: String
    public let timeout: Duration?

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let element = try await context.waitForVisible(selector, timeout: timeout)
        try await element.press(key)
    }
}

public struct ClearStep: BrowserTestStep {
    public let selector: Selector
    public let timeout: Duration?

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let element = try await context.waitForVisible(selector, timeout: timeout)
        try await element.clear()
    }
}

public struct CheckStep: BrowserTestStep {
    public let selector: Selector
    public let timeout: Duration?

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let element = try await context.waitForVisible(selector, timeout: timeout)
        try await element.check()
    }
}

public struct UncheckStep: BrowserTestStep {
    public let selector: Selector
    public let timeout: Duration?

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let element = try await context.waitForVisible(selector, timeout: timeout)
        try await element.uncheck()
    }
}

public struct SelectOptionStep: BrowserTestStep {
    public let selector: Selector
    public let value: String
    public let timeout: Duration?

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let element = try await context.waitForVisible(selector, timeout: timeout)
        try await element.selectOption(value)
    }
}

public struct HoverStep: BrowserTestStep {
    public let selector: Selector
    public let timeout: Duration?

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let element = try await context.waitForVisible(selector, timeout: timeout)
        try await element.hover()
    }
}

public struct FocusStep: BrowserTestStep {
    public let selector: Selector
    public let timeout: Duration?

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let element = try await context.waitForVisible(selector, timeout: timeout)
        try await element.focus()
    }
}

public struct BlurStep: BrowserTestStep {
    public let selector: Selector
    public let timeout: Duration?

    @MainActor public func run(in context: BrowserTestContext) async throws {
        let element = try await context.waitForVisible(selector, timeout: timeout)
        try await element.blur()
    }
}

// MARK: - Semantic Constructors

public func TextField(_ name: String, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .formField(.text, name: name), timeout: timeout)
}

public func SecureField(_ name: String, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .formField(.secure, name: name), timeout: timeout)
}

public func Select(_ name: String, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.combobox, name: name), timeout: timeout)
}

public func Checkbox(_ name: String, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.checkbox, name: name), timeout: timeout)
}

public func Radio(_ name: String, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.radio, name: name), timeout: timeout)
}

public func Button(_ name: String, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.button, name: name), timeout: timeout)
}

public func Link(_ name: String, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.link, name: name), timeout: timeout)
}

public func Heading(_ name: String, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.heading, name: name), timeout: timeout)
}

public func Image(_ name: String, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.img, name: name), timeout: timeout)
}

public func List(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.list, name: name), timeout: timeout)
}

public func ListItem(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.listItem, name: name), timeout: timeout)
}

public func Table(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.table, name: name), timeout: timeout)
}

public func Row(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.row, name: name), timeout: timeout)
}

public func Cell(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.cell, name: name), timeout: timeout)
}

public func ColumnHeader(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.columnHeader, name: name), timeout: timeout)
}

public func RowHeader(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.rowHeader, name: name), timeout: timeout)
}

public func MainContent(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.main, name: name), timeout: timeout)
}

public func Navigation(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.navigation, name: name), timeout: timeout)
}

public func Banner(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.banner, name: name), timeout: timeout)
}

public func Footer(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.contentInfo, name: name), timeout: timeout)
}

public func Form(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.form, name: name), timeout: timeout)
}

public func Region(_ name: String? = nil, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .role(.region, name: name), timeout: timeout)
}

public func Text(_ value: String, timeout: Duration? = nil) -> SemanticElement {
    SemanticElement(selector: .text(value), timeout: timeout)
}

import Foundation

@resultBuilder
public enum BrowserTestBuilder {
    public static func buildBlock(_ components: [BrowserTestStep]...) -> [BrowserTestStep] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: BrowserTestStep) -> [BrowserTestStep] {
        [expression]
    }

    public static func buildExpression(_ expression: [BrowserTestStep]) -> [BrowserTestStep] {
        expression
    }

    public static func buildOptional(_ component: [BrowserTestStep]?) -> [BrowserTestStep] {
        component ?? []
    }

    public static func buildEither(first component: [BrowserTestStep]) -> [BrowserTestStep] {
        component
    }

    public static func buildEither(second component: [BrowserTestStep]) -> [BrowserTestStep] {
        component
    }

    public static func buildArray(_ components: [[BrowserTestStep]]) -> [BrowserTestStep] {
        components.flatMap { $0 }
    }
}

public typealias BrowserTestContent = () -> [BrowserTestStep]

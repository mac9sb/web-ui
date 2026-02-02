import Foundation

public struct BrowserScript: Sendable {
    public let statements: [BrowserStatement]

    public init(@BrowserScriptBuilder _ build: () -> [BrowserStatement]) {
        self.statements = build()
    }

    public func render() throws -> String {
        let renderedStatements = try statements.map { try $0.render() }.joined(separator: ";\n")
        return """
        (() => {
            \(renderedStatements)
        })()
        """
    }
}

@resultBuilder
public enum BrowserScriptBuilder {
    public static func buildBlock(_ components: [BrowserStatement]...) -> [BrowserStatement] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: BrowserStatement) -> [BrowserStatement] {
        [expression]
    }

    public static func buildOptional(_ component: [BrowserStatement]?) -> [BrowserStatement] {
        component ?? []
    }

    public static func buildEither(first component: [BrowserStatement]) -> [BrowserStatement] {
        component
    }

    public static func buildEither(second component: [BrowserStatement]) -> [BrowserStatement] {
        component
    }

    public static func buildArray(_ components: [[BrowserStatement]]) -> [BrowserStatement] {
        components.flatMap { $0 }
    }
}

public enum BrowserStatement: Sendable {
    case setBodyHTML(String)
    case appendHeadScript(source: String)
    case appendHeadScriptURL(String)
    case click(selector: String)
    case setValue(selector: String, value: String, dispatchEvents: Bool)
    case returnBool(Bool)
    case custom(String)

    public static func setContent(_ html: String) -> BrowserStatement {
        .setBodyHTML(html)
    }

    public static func addScript(content: String) -> BrowserStatement {
        .appendHeadScript(source: content)
    }

    public static func addScript(url: String) -> BrowserStatement {
        .appendHeadScriptURL(url)
    }

    public func render() throws -> String {
        switch self {
        case .setBodyHTML(let html):
            let literal = try BrowserScriptString.literal(html)
            return "document.body.innerHTML = \(literal)"
        case .appendHeadScript(let source):
            let literal = try BrowserScriptString.literal(source)
            return """
            {
                const script = document.createElement('script');
                script.text = \(literal);
                document.head.appendChild(script);
            }
            """
        case .appendHeadScriptURL(let url):
            let literal = try BrowserScriptString.literal(url)
            return """
            {
                const script = document.createElement('script');
                script.src = \(literal);
                document.head.appendChild(script);
            }
            """
        case .click(let selector):
            let literal = try BrowserScriptString.literal(selector)
            return """
            {
                const el = document.querySelector(\(literal));
                if (el) { el.click(); }
            }
            """
        case .setValue(let selector, let value, let dispatchEvents):
            let selectorLiteral = try BrowserScriptString.literal(selector)
            let valueLiteral = try BrowserScriptString.literal(value)
            if dispatchEvents {
                return """
                {
                    const el = document.querySelector(\(selectorLiteral));
                    if (el) {
                        el.value = \(valueLiteral);
                        el.dispatchEvent(new Event('input', { bubbles: true }));
                        el.dispatchEvent(new Event('change', { bubbles: true }));
                    }
                }
                """
            }
            return """
            {
                const el = document.querySelector(\(selectorLiteral));
                if (el) { el.value = \(valueLiteral); }
            }
            """
        case .returnBool(let value):
            return "return \(value ? "true" : "false")"
        case .custom(let raw):
            return raw
        }
    }
}

enum BrowserScriptString {
    static func literal(_ value: String) throws -> String {
        let data = try JSONEncoder().encode(value)
        guard let string = String(data: data, encoding: .utf8) else {
            throw BrowserScriptRenderError.invalidStringLiteral
        }
        return string
    }
}

enum BrowserScriptRenderError: Error {
    case invalidStringLiteral
}

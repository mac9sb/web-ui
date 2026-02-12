import Foundation
import AxiomWebI18n

public struct HTMLAttribute: Hashable, Sendable {
    public let name: String
    public let value: String?

    public init(_ name: String, _ value: String? = nil) {
        self.name = name
        self.value = value
    }
}

public struct HTMLElementNode: Sendable, Equatable {
    public var tag: String
    public var attributes: [HTMLAttribute]
    public var children: [HTMLNode]

    public init(tag: String, attributes: [HTMLAttribute] = [], children: [HTMLNode] = []) {
        self.tag = tag
        self.attributes = attributes
        self.children = children
    }
}

public indirect enum HTMLNode: Sendable, Equatable {
    case text(String)
    case element(HTMLElementNode)

    public func rendered() -> String {
        switch self {
        case .text(let value):
            return HTMLEscape.escape(value)
        case .element(let element):
            let attrs = element.attributes.map { attr -> String in
                guard let value = attr.value else {
                    return attr.name
                }
                return "\(attr.name)=\"\(HTMLEscape.escapeAttribute(value))\""
            }
            let attributes = attrs.isEmpty ? "" : " " + attrs.joined(separator: " ")
            if HTMLVoidTags.contains(element.tag) {
                return "<\(element.tag)\(attributes)>"
            }
            let children = element.children.map { $0.rendered() }.joined()
            return "<\(element.tag)\(attributes)>\(children)</\(element.tag)>"
        }
    }

    public func addingAttribute(_ attribute: HTMLAttribute) -> HTMLNode {
        switch self {
        case .text(let value):
            return .element(
                HTMLElementNode(
                    tag: "span",
                    attributes: [attribute],
                    children: [.text(value)]
                )
            )
        case .element(var element):
            if let index = element.attributes.firstIndex(where: { $0.name == attribute.name }) {
                if attribute.name == "class",
                   let existing = element.attributes[index].value,
                   let incoming = attribute.value,
                   !existing.isEmpty
                {
                    element.attributes[index] = HTMLAttribute("class", "\(existing) \(incoming)")
                } else {
                    element.attributes[index] = attribute
                }
            } else {
                element.attributes.append(attribute)
            }
            return .element(element)
        }
    }
}

private let HTMLVoidTags: Set<String> = [
    "area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta",
    "source", "track", "wbr",
]

public protocol Markup {
    func makeNodes(locale: LocaleCode) -> [HTMLNode]
}

public extension Markup {
    func makeNodes() -> [HTMLNode] {
        makeNodes(locale: .en)
    }

    func renderHTML(locale: LocaleCode = .en) -> String {
        makeNodes(locale: locale).map { $0.rendered() }.joined()
    }
}

public struct AnyMarkup: Markup {
    private let storage: (LocaleCode) -> [HTMLNode]

    public init<M: Markup>(_ value: M) {
        self.storage = { locale in
            value.makeNodes(locale: locale)
        }
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        storage(locale)
    }
}

public struct EmptyMarkup: Markup {
    public init() {}

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        []
    }
}

@resultBuilder
public enum MarkupBuilder {
    public static func buildBlock(_ components: [AnyMarkup]...) -> [AnyMarkup] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [AnyMarkup]?) -> [AnyMarkup] {
        component ?? []
    }

    public static func buildEither(first component: [AnyMarkup]) -> [AnyMarkup] {
        component
    }

    public static func buildEither(second component: [AnyMarkup]) -> [AnyMarkup] {
        component
    }

    public static func buildArray(_ components: [[AnyMarkup]]) -> [AnyMarkup] {
        components.flatMap { $0 }
    }

    public static func buildExpression<M: Markup>(_ expression: M) -> [AnyMarkup] {
        [AnyMarkup(expression)]
    }

    public static func buildExpression(_ expression: String) -> [AnyMarkup] {
        [AnyMarkup(Text(expression))]
    }

    public static func buildExpression(_ expression: LocalizedText) -> [AnyMarkup] {
        [AnyMarkup(expression)]
    }

    public static func buildFinalResult(_ component: [AnyMarkup]) -> MarkupGroup {
        MarkupGroup(component)
    }
}

public struct MarkupGroup: Markup {
    public let content: [AnyMarkup]

    public init(_ content: [AnyMarkup]) {
        self.content = content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        content.flatMap { $0.makeNodes(locale: locale) }
    }
}

public protocol Element: Markup {
    associatedtype Body: Markup
    @MarkupBuilder
    var body: Body { get }
}

public extension Element {
    func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        body.makeNodes(locale: locale)
    }
}

public enum HTMLEscape {
    public static func escape(_ input: String) -> String {
        input
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    public static func escapeAttribute(_ input: String) -> String {
        escape(input)
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

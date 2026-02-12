import Foundation
import AxiomWebI18n

public struct Text: Markup {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.text(value)]
    }
}

public struct Node: Markup {
    public let tag: String
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        _ tag: String,
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup = { MarkupGroup([]) }
    ) {
        self.tag = tag
        self.attributes = attributes
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let children = content.flatMap { $0.makeNodes(locale: locale) }
        return [.element(HTMLElementNode(tag: tag, attributes: attributes, children: children))]
    }
}

public struct HTML: Markup {
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup
    ) {
        self.attributes = attributes
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let children = content.flatMap { $0.makeNodes(locale: locale) }
        return [.element(HTMLElementNode(tag: "html", attributes: attributes, children: children))]
    }
}

public struct Head: Markup {
    public let content: [AnyMarkup]

    public init(@MarkupBuilder content: () -> MarkupGroup) {
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(
            HTMLElementNode(
                tag: "head",
                children: content.flatMap { $0.makeNodes(locale: locale) }
            )
        )]
    }
}

public struct Body: Markup {
    public let content: [AnyMarkup]

    public init(@MarkupBuilder content: () -> MarkupGroup) {
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(
            HTMLElementNode(
                tag: "body",
                children: content.flatMap { $0.makeNodes(locale: locale) }
            )
        )]
    }
}

public struct Title: Markup {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "title", children: [.text(value)]))]
    }
}

public struct Meta: Markup {
    public let attributes: [HTMLAttribute]

    public init(attributes: [HTMLAttribute]) {
        self.attributes = attributes
    }

    public init(name: String, content: String) {
        self.attributes = [HTMLAttribute("name", name), HTMLAttribute("content", content)]
    }

    public init(property: String, content: String) {
        self.attributes = [HTMLAttribute("property", property), HTMLAttribute("content", content)]
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "meta", attributes: attributes))]
    }
}

public struct LinkTag: Markup {
    public let attributes: [HTMLAttribute]

    public init(rel: String, href: String, extra: [HTMLAttribute] = []) {
        self.attributes = [HTMLAttribute("rel", rel), HTMLAttribute("href", href)] + extra
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "link", attributes: attributes))]
    }
}

public struct ScriptTag: Markup {
    public let attributes: [HTMLAttribute]
    public let value: String

    public init(type: String? = nil, src: String? = nil, content: String = "") {
        var attrs: [HTMLAttribute] = []
        if let type { attrs.append(HTMLAttribute("type", type)) }
        if let src { attrs.append(HTMLAttribute("src", src)) }
        self.attributes = attrs
        self.value = content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "script", attributes: attributes, children: value.isEmpty ? [] : [.text(value)]))]
    }
}

public struct Div: Markup {
    public let content: [AnyMarkup]

    public init(@MarkupBuilder content: () -> MarkupGroup) {
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "div", children: content.flatMap { $0.makeNodes(locale: locale) }))]
    }
}

public struct Main: Markup {
    public let content: [AnyMarkup]

    public init(@MarkupBuilder content: () -> MarkupGroup) {
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "main", children: content.flatMap { $0.makeNodes(locale: locale) }))]
    }
}

public struct Header: Markup {
    public let content: [AnyMarkup]

    public init(@MarkupBuilder content: () -> MarkupGroup) {
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "header", children: content.flatMap { $0.makeNodes(locale: locale) }))]
    }
}

public struct Footer: Markup {
    public let content: [AnyMarkup]

    public init(@MarkupBuilder content: () -> MarkupGroup) {
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "footer", children: content.flatMap { $0.makeNodes(locale: locale) }))]
    }
}

public struct Section: Markup {
    public let content: [AnyMarkup]

    public init(@MarkupBuilder content: () -> MarkupGroup) {
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "section", children: content.flatMap { $0.makeNodes(locale: locale) }))]
    }
}

public struct Paragraph: Markup {
    public let content: [AnyMarkup]

    public init(@MarkupBuilder content: () -> MarkupGroup) {
        self.content = content().content
    }

    public init(_ value: String) {
        self.content = [AnyMarkup(Text(value))]
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "p", children: content.flatMap { $0.makeNodes(locale: locale) }))]
    }
}

public struct Heading: Markup {
    public enum Level: Int, Sendable {
        case h1 = 1
        case h2 = 2
        case h3 = 3
        case h4 = 4
        case h5 = 5
        case h6 = 6

        var tag: String { "h\(rawValue)" }
    }

    public let level: Level
    public let value: String

    public init(_ level: Level, _ value: String) {
        self.level = level
        self.value = value
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: level.tag, children: [.text(value)]))]
    }
}

public struct Link: Markup {
    public let href: String
    public let content: [AnyMarkup]

    public init(_ href: String, @MarkupBuilder content: () -> MarkupGroup) {
        self.href = href
        self.content = content().content
    }

    public init(_ title: String, href: String) {
        self.href = href
        self.content = [AnyMarkup(Text(title))]
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(
            HTMLElementNode(
                tag: "a",
                attributes: [HTMLAttribute("href", href)],
                children: content.flatMap { $0.makeNodes(locale: locale) }
            )
        )]
    }
}

public struct FormElement: Markup {
    public let action: String
    public let method: String
    public let content: [AnyMarkup]

    public init(action: String, method: String = "post", @MarkupBuilder content: () -> MarkupGroup) {
        self.action = action
        self.method = method
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(
            HTMLElementNode(
                tag: "form",
                attributes: [HTMLAttribute("action", action), HTMLAttribute("method", method)],
                children: content.flatMap { $0.makeNodes(locale: locale) }
            )
        )]
    }
}

public struct Input: Markup {
    public let name: String
    public let type: String
    public let placeholder: String?
    public let required: Bool
    public let id: String?

    public init(name: String, type: String = "text", placeholder: String? = nil, required: Bool = false, id: String? = nil) {
        self.name = name
        self.type = type
        self.placeholder = placeholder
        self.required = required
        self.id = id
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        var attrs: [HTMLAttribute] = [
            HTMLAttribute("name", name),
            HTMLAttribute("type", type),
        ]
        if let placeholder { attrs.append(HTMLAttribute("placeholder", placeholder)) }
        if required { attrs.append(HTMLAttribute("required")) }
        if let id { attrs.append(HTMLAttribute("id", id)) }
        return [.element(HTMLElementNode(tag: "input", attributes: attrs))]
    }
}

public struct TextArea: Markup {
    public let name: String
    public let placeholder: String?
    public let required: Bool
    public let id: String?

    public init(name: String, placeholder: String? = nil, required: Bool = false, id: String? = nil) {
        self.name = name
        self.placeholder = placeholder
        self.required = required
        self.id = id
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        var attrs: [HTMLAttribute] = [HTMLAttribute("name", name)]
        if let placeholder { attrs.append(HTMLAttribute("placeholder", placeholder)) }
        if required { attrs.append(HTMLAttribute("required")) }
        if let id { attrs.append(HTMLAttribute("id", id)) }
        return [.element(HTMLElementNode(tag: "textarea", attributes: attrs))]
    }
}

public struct Label: Markup {
    public let target: String
    public let value: String

    public init(for target: String, _ value: String) {
        self.target = target
        self.value = value
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "label", attributes: [HTMLAttribute("for", target)], children: [.text(value)]))]
    }
}

public struct Button: Markup {
    public let title: String
    public let type: String

    public init(_ title: String, type: String = "button") {
        self.title = title
        self.type = type
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "button", attributes: [HTMLAttribute("type", type)], children: [.text(title)]))]
    }
}

public struct Details: Markup {
    public let content: [AnyMarkup]

    public init(@MarkupBuilder content: () -> MarkupGroup) {
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "details", children: content.flatMap { $0.makeNodes(locale: locale) }))]
    }
}

public struct Summary: Markup {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "summary", children: [.text(value)]))]
    }
}

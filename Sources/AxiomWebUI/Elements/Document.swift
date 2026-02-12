import Foundation
import AxiomWebI18n

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

public struct ResourceLink: HTMLTagElement {
    public static let tagName: HTMLTagName = .link
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct Base: HTMLTagElement {
    public static let tagName: HTMLTagName = .base
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct Style: HTMLTagElement {
    public static let tagName: HTMLTagName = .style
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup = { MarkupGroup([]) }
    ) {
        self.attributes = attributes
        self.content = content().content
    }
}

public struct NoScript: HTMLTagElement {
    public static let tagName: HTMLTagName = .noscript
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup = { MarkupGroup([]) }
    ) {
        self.attributes = attributes
        self.content = content().content
    }
}

public struct Template: HTMLTagElement {
    public static let tagName: HTMLTagName = .template
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup = { MarkupGroup([]) }
    ) {
        self.attributes = attributes
        self.content = content().content
    }
}

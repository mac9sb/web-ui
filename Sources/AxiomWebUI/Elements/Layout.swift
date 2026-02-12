import Foundation
import AxiomWebI18n

public struct Stack: Markup {
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

public struct Article: HTMLTagElement {
    public static let tagName: HTMLTagName = .article
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

public struct Aside: HTMLTagElement {
    public static let tagName: HTMLTagName = .aside
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

public struct Address: HTMLTagElement {
    public static let tagName: HTMLTagName = .address
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

public struct Navigation: HTMLTagElement {
    public static let tagName: HTMLTagName = .nav
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

public struct HeadingGroup: HTMLTagElement {
    public static let tagName: HTMLTagName = .hgroup
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

public struct Search: HTMLTagElement {
    public static let tagName: HTMLTagName = .search
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

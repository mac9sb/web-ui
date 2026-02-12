import Foundation
import AxiomWebI18n

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

public struct Dialog: HTMLTagElement {
    public static let tagName: HTMLTagName = .dialog
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

public struct Slot: HTMLTagElement {
    public static let tagName: HTMLTagName = .slot
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

public struct Portal: HTMLTagElement {
    public static let tagName: HTMLTagName = .portal
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

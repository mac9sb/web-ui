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

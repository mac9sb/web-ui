import Foundation
import AxiomWebI18n

public struct Text: Markup {
    public enum Rendering: Sendable, Equatable {
        case automaticTag
        case raw
    }

    public let value: String
    public let rendering: Rendering

    public init(_ value: String, rendering: Rendering = .automaticTag) {
        self.value = value
        self.rendering = rendering
    }

    public static func raw(_ value: String) -> Text {
        Text(value, rendering: .raw)
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        switch rendering {
        case .raw:
            return [.text(value)]
        case .automaticTag:
            let tag = inferredTag(for: value)
            return [.element(HTMLElementNode(tag: tag, children: [.text(value)]))]
        }
    }

    private func inferredTag(for value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let isLongForm = trimmed.count > 72 || trimmed.contains("\n")
        return isLongForm ? "p" : "span"
    }
}

public struct RawText: Markup {
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

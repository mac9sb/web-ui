import Foundation
import AxiomWebI18n

public struct Details: HTMLTagElement {
    public static let tagName: HTMLTagName = .details
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup
    ) {
        self.attributes = attributes
        self.content = content().content
    }
}

public struct Summary: HTMLTagElement {
    public static let tagName: HTMLTagName = .summary
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(_ value: String, attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
        self.content = [AnyMarkup(RawText(value))]
    }

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup
    ) {
        self.attributes = attributes
        self.content = content().content
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

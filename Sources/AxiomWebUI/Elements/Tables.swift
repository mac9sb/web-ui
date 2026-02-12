import Foundation
import AxiomWebI18n

public struct Table: HTMLTagElement {
    public static let tagName: HTMLTagName = .table
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

public struct Caption: HTMLTagElement {
    public static let tagName: HTMLTagName = .caption
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

public struct Column: HTMLTagElement {
    public static let tagName: HTMLTagName = .col
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct ColumnGroup: HTMLTagElement {
    public static let tagName: HTMLTagName = .colgroup
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

public struct TableHead: HTMLTagElement {
    public static let tagName: HTMLTagName = .thead
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

public struct TableBody: HTMLTagElement {
    public static let tagName: HTMLTagName = .tbody
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

public struct TableFooter: HTMLTagElement {
    public static let tagName: HTMLTagName = .tfoot
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

public struct TableRow: HTMLTagElement {
    public static let tagName: HTMLTagName = .tr
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

public struct TableHeader: HTMLTagElement {
    public static let tagName: HTMLTagName = .th
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

public struct TableCell: HTMLTagElement {
    public static let tagName: HTMLTagName = .td
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

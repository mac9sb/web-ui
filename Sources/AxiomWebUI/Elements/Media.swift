import Foundation
import AxiomWebI18n

public struct Area: HTMLTagElement {
    public static let tagName: HTMLTagName = .area
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct Audio: HTMLTagElement {
    public static let tagName: HTMLTagName = .audio
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

public struct Canvas: HTMLTagElement {
    public static let tagName: HTMLTagName = .canvas
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

public struct Embed: HTMLTagElement {
    public static let tagName: HTMLTagName = .embed
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct Figure: HTMLTagElement {
    public static let tagName: HTMLTagName = .figure
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

public struct FigureCaption: HTMLTagElement {
    public static let tagName: HTMLTagName = .figcaption
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

public struct Image: HTMLTagElement {
    public static let tagName: HTMLTagName = .img
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct ImageMap: HTMLTagElement {
    public static let tagName: HTMLTagName = .map
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

public struct Picture: HTMLTagElement {
    public static let tagName: HTMLTagName = .picture
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

public struct Source: HTMLTagElement {
    public static let tagName: HTMLTagName = .source
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct SVG: HTMLTagElement {
    public static let tagName: HTMLTagName = .svg
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

public struct Track: HTMLTagElement {
    public static let tagName: HTMLTagName = .track
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct Video: HTMLTagElement {
    public static let tagName: HTMLTagName = .video
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

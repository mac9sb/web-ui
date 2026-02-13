import Foundation
import AxiomWebI18n

public struct Paragraph: HTMLTagElement {
    public static let tagName: HTMLTagName = .p
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup
    ) {
        self.attributes = attributes
        self.content = content().content
    }

    public init(_ value: String, attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
        self.content = [AnyMarkup(RawText(value))]
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

public struct Link: HTMLTagElement {
    public static let tagName: HTMLTagName = .a
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(_ href: String, @MarkupBuilder content: () -> MarkupGroup) {
        self.attributes = [HTMLAttribute("href", href)]
        self.content = content().content
    }

    public init(_ title: String, href: String) {
        self.init(href) {
            RawText(title)
        }
    }
}

public struct Abbreviation: HTMLTagElement {
    public static let tagName: HTMLTagName = .abbr
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

public struct Bold: HTMLTagElement {
    public static let tagName: HTMLTagName = .b
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

public struct BidirectionalIsolation: HTMLTagElement {
    public static let tagName: HTMLTagName = .bdi
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

public struct BidirectionalOverride: HTMLTagElement {
    public static let tagName: HTMLTagName = .bdo
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

public struct Blockquote: HTMLTagElement {
    public static let tagName: HTMLTagName = .blockquote
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

public struct LineBreak: HTMLTagElement {
    public static let tagName: HTMLTagName = .br
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct HorizontalRule: HTMLTagElement {
    public static let tagName: HTMLTagName = .hr
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct Citation: HTMLTagElement {
    public static let tagName: HTMLTagName = .cite
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

public struct Code: HTMLTagElement {
    public static let tagName: HTMLTagName = .code
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

public struct Definition: HTMLTagElement {
    public static let tagName: HTMLTagName = .dfn
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

public struct Emphasis: HTMLTagElement {
    public static let tagName: HTMLTagName = .em
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

public struct H1: HTMLTagElement {
    public static let tagName: HTMLTagName = .h1
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

public struct H2: HTMLTagElement {
    public static let tagName: HTMLTagName = .h2
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

public struct H3: HTMLTagElement {
    public static let tagName: HTMLTagName = .h3
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

public struct H4: HTMLTagElement {
    public static let tagName: HTMLTagName = .h4
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

public struct H5: HTMLTagElement {
    public static let tagName: HTMLTagName = .h5
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

public struct H6: HTMLTagElement {
    public static let tagName: HTMLTagName = .h6
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

public struct Italic: HTMLTagElement {
    public static let tagName: HTMLTagName = .i
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

public struct InsertedText: HTMLTagElement {
    public static let tagName: HTMLTagName = .ins
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

public struct KeyboardInput: HTMLTagElement {
    public static let tagName: HTMLTagName = .kbd
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

public struct Mark: HTMLTagElement {
    public static let tagName: HTMLTagName = .mark
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

public struct Preformatted: HTMLTagElement {
    public static let tagName: HTMLTagName = .pre
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

public struct InlineQuote: HTMLTagElement {
    public static let tagName: HTMLTagName = .q
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

public struct RubyParenthesis: HTMLTagElement {
    public static let tagName: HTMLTagName = .rp
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

public struct RubyText: HTMLTagElement {
    public static let tagName: HTMLTagName = .rt
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

public struct Ruby: HTMLTagElement {
    public static let tagName: HTMLTagName = .ruby
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

public struct Strikethrough: HTMLTagElement {
    public static let tagName: HTMLTagName = .s
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

public struct Sample: HTMLTagElement {
    public static let tagName: HTMLTagName = .samp
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

public struct Small: HTMLTagElement {
    public static let tagName: HTMLTagName = .small
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

public struct Span: HTMLTagElement {
    public static let tagName: HTMLTagName = .span
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

public struct Strong: HTMLTagElement {
    public static let tagName: HTMLTagName = .strong
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

public struct SubscriptText: HTMLTagElement {
    public static let tagName: HTMLTagName = .sub
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

public struct SuperscriptText: HTMLTagElement {
    public static let tagName: HTMLTagName = .sup
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

public struct Time: HTMLTagElement {
    public static let tagName: HTMLTagName = .time
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

public struct Underline: HTMLTagElement {
    public static let tagName: HTMLTagName = .u
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

public struct VariableText: HTMLTagElement {
    public static let tagName: HTMLTagName = .`var`
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

public struct WordBreakOpportunity: HTMLTagElement {
    public static let tagName: HTMLTagName = .wbr
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct DeletedText: HTMLTagElement {
    public static let tagName: HTMLTagName = .del
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

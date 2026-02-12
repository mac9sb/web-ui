import Foundation
import AxiomWebI18n

// Broad HTML tag coverage for the generic `HTMLTag` API.
public enum HTMLTagName: String, Sendable, CaseIterable {
    case a
    case abbr
    case address
    case area
    case article
    case aside
    case audio
    case b
    case base
    case bdi
    case bdo
    case blockquote
    case body
    case br
    case button
    case canvas
    case caption
    case cite
    case code
    case col
    case colgroup
    case data
    case datalist
    case dd
    case del
    case details
    case dfn
    case dialog
    case div
    case dl
    case dt
    case em
    case embed
    case fieldset
    case figcaption
    case figure
    case footer
    case form
    case h1
    case h2
    case h3
    case h4
    case h5
    case h6
    case head
    case header
    case hgroup
    case hr
    case html
    case i
    case iframe
    case img
    case input
    case ins
    case kbd
    case label
    case legend
    case li
    case link
    case main
    case map
    case mark
    case math
    case menu
    case meta
    case meter
    case nav
    case noscript
    case object
    case ol
    case optgroup
    case option
    case output
    case p
    case picture
    case portal
    case pre
    case progress
    case q
    case rp
    case rt
    case ruby
    case s
    case samp
    case script
    case search
    case section
    case select
    case slot
    case small
    case source
    case span
    case strong
    case style
    case sub
    case summary
    case sup
    case svg
    case table
    case tbody
    case td
    case template
    case textarea
    case tfoot
    case th
    case thead
    case time
    case title
    case tr
    case track
    case u
    case ul
    case `var` = "var"
    case video
    case wbr
}

public extension HTMLTagName {
    static let supportedNames: Set<String> = Set(Self.allCases.map(\.rawValue))
}

public struct HTMLTag: Markup {
    public let name: HTMLTagName
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        _ name: HTMLTagName,
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup = { MarkupGroup([]) }
    ) {
        self.name = name
        self.attributes = attributes
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let children = content.flatMap { $0.makeNodes(locale: locale) }
        return [.element(HTMLElementNode(tag: name.rawValue, attributes: attributes, children: children))]
    }
}

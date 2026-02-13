import Foundation
import AxiomWebI18n

// Shared support for strongly-typed HTML element members.
public protocol HTMLTagElement: Markup {
    static var tagName: HTMLTagName { get }
    var attributes: [HTMLAttribute] { get }
    var content: [AnyMarkup] { get }
}

public extension HTMLTagElement {
    func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let children = content.flatMap { $0.makeNodes(locale: locale) }
        return [.element(HTMLElementNode(tag: Self.tagName.rawValue, attributes: attributes, children: children))]
    }
}

public extension HTMLTagName {
    static let dslCoveredNames: Set<String> = Self.supportedNames
}

import Foundation
import AxiomWebUI

public extension CSSProperty {
    static let captionSide: CSSProperty = "caption-side"
    static let emptyCells: CSSProperty = "empty-cells"
    static let listStyle: CSSProperty = "list-style"
    static let tableLayout: CSSProperty = "table-layout"
}

public extension Markup {
    func captionSide(_ value: CSSValue) -> some Markup {
        css(.captionSide, value)
    }

    func emptyCells(_ value: CSSValue) -> some Markup {
        css(.emptyCells, value)
    }

    func listStyle(_ value: CSSValue) -> some Markup {
        css(.listStyle, value)
    }

    func tableLayout(_ value: CSSValue) -> some Markup {
        css(.tableLayout, value)
    }

}

public extension VariantScope {
    func captionSide(_ value: CSSValue) {
        css(.captionSide, value)
    }

    func emptyCells(_ value: CSSValue) {
        css(.emptyCells, value)
    }

    func listStyle(_ value: CSSValue) {
        css(.listStyle, value)
    }

    func tableLayout(_ value: CSSValue) {
        css(.tableLayout, value)
    }

}
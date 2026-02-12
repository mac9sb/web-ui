import Foundation
import AxiomWebUI

public extension CSSProperty {
    static let backfaceVisibility: CSSProperty = "backface-visibility"
    static let breakAfter: CSSProperty = "break-after"
    static let breakBefore: CSSProperty = "break-before"
    static let breakInside: CSSProperty = "break-inside"
}

public extension Markup {
    func backfaceVisibility(_ value: CSSValue) -> some Markup {
        css(.backfaceVisibility, value)
    }

    func breakAfter(_ value: CSSValue) -> some Markup {
        css(.breakAfter, value)
    }

    func breakBefore(_ value: CSSValue) -> some Markup {
        css(.breakBefore, value)
    }

    func breakInside(_ value: CSSValue) -> some Markup {
        css(.breakInside, value)
    }

}

public extension VariantScope {
    func backfaceVisibility(_ value: CSSValue) {
        css(.backfaceVisibility, value)
    }

    func breakAfter(_ value: CSSValue) {
        css(.breakAfter, value)
    }

    func breakBefore(_ value: CSSValue) {
        css(.breakBefore, value)
    }

    func breakInside(_ value: CSSValue) {
        css(.breakInside, value)
    }

}
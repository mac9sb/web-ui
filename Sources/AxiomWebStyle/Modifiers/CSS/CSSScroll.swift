import Foundation
import AxiomWebUI

public extension CSSProperty {
    static let scrollBehavior: CSSProperty = "scroll-behavior"
    static let scrollMargin: CSSProperty = "scroll-margin"
    static let scrollMarginBlock: CSSProperty = "scroll-margin-block"
    static let scrollMarginInline: CSSProperty = "scroll-margin-inline"
    static let scrollPadding: CSSProperty = "scroll-padding"
    static let scrollPaddingBlock: CSSProperty = "scroll-padding-block"
    static let scrollPaddingInline: CSSProperty = "scroll-padding-inline"
    static let scrollSnapAlign: CSSProperty = "scroll-snap-align"
    static let scrollSnapStop: CSSProperty = "scroll-snap-stop"
    static let scrollSnapType: CSSProperty = "scroll-snap-type"
    static let scrollbarGutter: CSSProperty = "scrollbar-gutter"
    static let scrollbarWidth: CSSProperty = "scrollbar-width"
}

public extension Markup {
    func scrollBehavior(_ value: CSSValue) -> some Markup {
        css(.scrollBehavior, value)
    }

    func scrollMargin(_ value: CSSValue) -> some Markup {
        css(.scrollMargin, value)
    }

    func scrollMarginBlock(_ value: CSSValue) -> some Markup {
        css(.scrollMarginBlock, value)
    }

    func scrollMarginInline(_ value: CSSValue) -> some Markup {
        css(.scrollMarginInline, value)
    }

    func scrollPadding(_ value: CSSValue) -> some Markup {
        css(.scrollPadding, value)
    }

    func scrollPaddingBlock(_ value: CSSValue) -> some Markup {
        css(.scrollPaddingBlock, value)
    }

    func scrollPaddingInline(_ value: CSSValue) -> some Markup {
        css(.scrollPaddingInline, value)
    }

    func scrollSnapAlign(_ value: CSSValue) -> some Markup {
        css(.scrollSnapAlign, value)
    }

    func scrollSnapStop(_ value: CSSValue) -> some Markup {
        css(.scrollSnapStop, value)
    }

    func scrollSnapType(_ value: CSSValue) -> some Markup {
        css(.scrollSnapType, value)
    }

    func scrollbarGutter(_ value: CSSValue) -> some Markup {
        css(.scrollbarGutter, value)
    }

    func scrollbarWidth(_ value: CSSValue) -> some Markup {
        css(.scrollbarWidth, value)
    }

}

public extension VariantScope {
    func scrollBehavior(_ value: CSSValue) {
        css(.scrollBehavior, value)
    }

    func scrollMargin(_ value: CSSValue) {
        css(.scrollMargin, value)
    }

    func scrollMarginBlock(_ value: CSSValue) {
        css(.scrollMarginBlock, value)
    }

    func scrollMarginInline(_ value: CSSValue) {
        css(.scrollMarginInline, value)
    }

    func scrollPadding(_ value: CSSValue) {
        css(.scrollPadding, value)
    }

    func scrollPaddingBlock(_ value: CSSValue) {
        css(.scrollPaddingBlock, value)
    }

    func scrollPaddingInline(_ value: CSSValue) {
        css(.scrollPaddingInline, value)
    }

    func scrollSnapAlign(_ value: CSSValue) {
        css(.scrollSnapAlign, value)
    }

    func scrollSnapStop(_ value: CSSValue) {
        css(.scrollSnapStop, value)
    }

    func scrollSnapType(_ value: CSSValue) {
        css(.scrollSnapType, value)
    }

    func scrollbarGutter(_ value: CSSValue) {
        css(.scrollbarGutter, value)
    }

    func scrollbarWidth(_ value: CSSValue) {
        css(.scrollbarWidth, value)
    }

}
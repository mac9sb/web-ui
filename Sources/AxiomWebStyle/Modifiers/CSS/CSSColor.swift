import Foundation
import AxiomWebUI

public extension CSSProperty {
    static let accentColor: CSSProperty = "accent-color"
    static let background: CSSProperty = "background"
    static let backgroundAttachment: CSSProperty = "background-attachment"
    static let backgroundBlendMode: CSSProperty = "background-blend-mode"
    static let backgroundClip: CSSProperty = "background-clip"
    static let backgroundColor: CSSProperty = "background-color"
    static let backgroundImage: CSSProperty = "background-image"
    static let backgroundOrigin: CSSProperty = "background-origin"
    static let backgroundPosition: CSSProperty = "background-position"
    static let backgroundRepeat: CSSProperty = "background-repeat"
    static let backgroundSize: CSSProperty = "background-size"
    static let caretColor: CSSProperty = "caret-color"
    static let color: CSSProperty = "color"
    static let scrollbarColor: CSSProperty = "scrollbar-color"
}

public extension Markup {
    func accentColor(_ value: CSSValue) -> some Markup {
        css(.accentColor, value)
    }

    func background(_ value: CSSValue) -> some Markup {
        css(.background, value)
    }

    func backgroundAttachment(_ value: CSSValue) -> some Markup {
        css(.backgroundAttachment, value)
    }

    func backgroundBlendMode(_ value: CSSValue) -> some Markup {
        css(.backgroundBlendMode, value)
    }

    func backgroundClip(_ value: CSSValue) -> some Markup {
        css(.backgroundClip, value)
    }

    func backgroundColor(_ value: CSSValue) -> some Markup {
        css(.backgroundColor, value)
    }

    func backgroundImage(_ value: CSSValue) -> some Markup {
        css(.backgroundImage, value)
    }

    func backgroundOrigin(_ value: CSSValue) -> some Markup {
        css(.backgroundOrigin, value)
    }

    func backgroundPosition(_ value: CSSValue) -> some Markup {
        css(.backgroundPosition, value)
    }

    func backgroundRepeat(_ value: CSSValue) -> some Markup {
        css(.backgroundRepeat, value)
    }

    func backgroundSize(_ value: CSSValue) -> some Markup {
        css(.backgroundSize, value)
    }

    func caretColor(_ value: CSSValue) -> some Markup {
        css(.caretColor, value)
    }

    func color(_ value: CSSValue) -> some Markup {
        css(.color, value)
    }

    func scrollbarColor(_ value: CSSValue) -> some Markup {
        css(.scrollbarColor, value)
    }

}

public extension VariantScope {
    func accentColor(_ value: CSSValue) {
        css(.accentColor, value)
    }

    func background(_ value: CSSValue) {
        css(.background, value)
    }

    func backgroundAttachment(_ value: CSSValue) {
        css(.backgroundAttachment, value)
    }

    func backgroundBlendMode(_ value: CSSValue) {
        css(.backgroundBlendMode, value)
    }

    func backgroundClip(_ value: CSSValue) {
        css(.backgroundClip, value)
    }

    func backgroundColor(_ value: CSSValue) {
        css(.backgroundColor, value)
    }

    func backgroundImage(_ value: CSSValue) {
        css(.backgroundImage, value)
    }

    func backgroundOrigin(_ value: CSSValue) {
        css(.backgroundOrigin, value)
    }

    func backgroundPosition(_ value: CSSValue) {
        css(.backgroundPosition, value)
    }

    func backgroundRepeat(_ value: CSSValue) {
        css(.backgroundRepeat, value)
    }

    func backgroundSize(_ value: CSSValue) {
        css(.backgroundSize, value)
    }

    func caretColor(_ value: CSSValue) {
        css(.caretColor, value)
    }

    func color(_ value: CSSValue) {
        css(.color, value)
    }

    func scrollbarColor(_ value: CSSValue) {
        css(.scrollbarColor, value)
    }

}
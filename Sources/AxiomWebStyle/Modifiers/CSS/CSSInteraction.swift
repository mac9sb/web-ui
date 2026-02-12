import Foundation
import AxiomWebUI

public extension CSSProperty {
    static let appearance: CSSProperty = "appearance"
    static let content: CSSProperty = "content"
    static let cursor: CSSProperty = "cursor"
    static let pointerEvents: CSSProperty = "pointer-events"
    static let touchAction: CSSProperty = "touch-action"
    static let userSelect: CSSProperty = "user-select"
}

public extension Markup {
    func appearance(_ value: CSSValue) -> some Markup {
        css(.appearance, value)
    }

    func content(_ value: CSSValue) -> some Markup {
        css(.content, value)
    }

    func cursor(_ value: CSSValue) -> some Markup {
        css(.cursor, value)
    }

    func pointerEvents(_ value: CSSValue) -> some Markup {
        css(.pointerEvents, value)
    }

    func touchAction(_ value: CSSValue) -> some Markup {
        css(.touchAction, value)
    }

    func userSelect(_ value: CSSValue) -> some Markup {
        css(.userSelect, value)
    }

}

public extension VariantScope {
    func appearance(_ value: CSSValue) {
        css(.appearance, value)
    }

    func content(_ value: CSSValue) {
        css(.content, value)
    }

    func cursor(_ value: CSSValue) {
        css(.cursor, value)
    }

    func pointerEvents(_ value: CSSValue) {
        css(.pointerEvents, value)
    }

    func touchAction(_ value: CSSValue) {
        css(.touchAction, value)
    }

    func userSelect(_ value: CSSValue) {
        css(.userSelect, value)
    }

}
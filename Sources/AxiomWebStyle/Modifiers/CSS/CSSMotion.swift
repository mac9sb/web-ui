import Foundation
import AxiomWebUI

public extension CSSProperty {
    static let animation: CSSProperty = "animation"
    static let animationDelay: CSSProperty = "animation-delay"
    static let animationDirection: CSSProperty = "animation-direction"
    static let animationDuration: CSSProperty = "animation-duration"
    static let animationFillMode: CSSProperty = "animation-fill-mode"
    static let animationIterationCount: CSSProperty = "animation-iteration-count"
    static let animationName: CSSProperty = "animation-name"
    static let animationPlayState: CSSProperty = "animation-play-state"
    static let animationTimingFunction: CSSProperty = "animation-timing-function"
    static let transition: CSSProperty = "transition"
    static let transitionDelay: CSSProperty = "transition-delay"
    static let transitionDuration: CSSProperty = "transition-duration"
    static let transitionProperty: CSSProperty = "transition-property"
    static let transitionTimingFunction: CSSProperty = "transition-timing-function"
    static let willChange: CSSProperty = "will-change"
}

public extension Markup {
    func animation(_ value: CSSValue) -> some Markup {
        css(.animation, value)
    }

    func animationDelay(_ value: CSSValue) -> some Markup {
        css(.animationDelay, value)
    }

    func animationDirection(_ value: CSSValue) -> some Markup {
        css(.animationDirection, value)
    }

    func animationDuration(_ value: CSSValue) -> some Markup {
        css(.animationDuration, value)
    }

    func animationFillMode(_ value: CSSValue) -> some Markup {
        css(.animationFillMode, value)
    }

    func animationIterationCount(_ value: CSSValue) -> some Markup {
        css(.animationIterationCount, value)
    }

    func animationName(_ value: CSSValue) -> some Markup {
        css(.animationName, value)
    }

    func animationPlayState(_ value: CSSValue) -> some Markup {
        css(.animationPlayState, value)
    }

    func animationTimingFunction(_ value: CSSValue) -> some Markup {
        css(.animationTimingFunction, value)
    }

    func transition(_ value: CSSValue) -> some Markup {
        css(.transition, value)
    }

    func transitionDelay(_ value: CSSValue) -> some Markup {
        css(.transitionDelay, value)
    }

    func transitionDuration(_ value: CSSValue) -> some Markup {
        css(.transitionDuration, value)
    }

    func transitionProperty(_ value: CSSValue) -> some Markup {
        css(.transitionProperty, value)
    }

    func transitionTimingFunction(_ value: CSSValue) -> some Markup {
        css(.transitionTimingFunction, value)
    }

    func willChange(_ value: CSSValue) -> some Markup {
        css(.willChange, value)
    }

}

public extension VariantScope {
    func animation(_ value: CSSValue) {
        css(.animation, value)
    }

    func animationDelay(_ value: CSSValue) {
        css(.animationDelay, value)
    }

    func animationDirection(_ value: CSSValue) {
        css(.animationDirection, value)
    }

    func animationDuration(_ value: CSSValue) {
        css(.animationDuration, value)
    }

    func animationFillMode(_ value: CSSValue) {
        css(.animationFillMode, value)
    }

    func animationIterationCount(_ value: CSSValue) {
        css(.animationIterationCount, value)
    }

    func animationName(_ value: CSSValue) {
        css(.animationName, value)
    }

    func animationPlayState(_ value: CSSValue) {
        css(.animationPlayState, value)
    }

    func animationTimingFunction(_ value: CSSValue) {
        css(.animationTimingFunction, value)
    }

    func transition(_ value: CSSValue) {
        css(.transition, value)
    }

    func transitionDelay(_ value: CSSValue) {
        css(.transitionDelay, value)
    }

    func transitionDuration(_ value: CSSValue) {
        css(.transitionDuration, value)
    }

    func transitionProperty(_ value: CSSValue) {
        css(.transitionProperty, value)
    }

    func transitionTimingFunction(_ value: CSSValue) {
        css(.transitionTimingFunction, value)
    }

    func willChange(_ value: CSSValue) {
        css(.willChange, value)
    }

}
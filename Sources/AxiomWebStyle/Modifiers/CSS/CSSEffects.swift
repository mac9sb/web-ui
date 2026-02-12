import Foundation
import AxiomWebUI

public extension CSSProperty {
    static let backdropFilter: CSSProperty = "backdrop-filter"
    static let clipPath: CSSProperty = "clip-path"
    static let filter: CSSProperty = "filter"
    static let mask: CSSProperty = "mask"
    static let mixBlendMode: CSSProperty = "mix-blend-mode"
    static let objectFit: CSSProperty = "object-fit"
    static let objectPosition: CSSProperty = "object-position"
    static let opacity: CSSProperty = "opacity"
    static let perspective: CSSProperty = "perspective"
    static let perspectiveOrigin: CSSProperty = "perspective-origin"
    static let rotate: CSSProperty = "rotate"
    static let scale: CSSProperty = "scale"
    static let shapeImageThreshold: CSSProperty = "shape-image-threshold"
    static let shapeMargin: CSSProperty = "shape-margin"
    static let shapeOutside: CSSProperty = "shape-outside"
    static let transform: CSSProperty = "transform"
    static let transformOrigin: CSSProperty = "transform-origin"
    static let transformStyle: CSSProperty = "transform-style"
    static let translate: CSSProperty = "translate"
}

public extension Markup {
    func backdropFilter(_ value: CSSValue) -> some Markup {
        css(.backdropFilter, value)
    }

    func clipPath(_ value: CSSValue) -> some Markup {
        css(.clipPath, value)
    }

    func filter(_ value: CSSValue) -> some Markup {
        css(.filter, value)
    }

    func mask(_ value: CSSValue) -> some Markup {
        css(.mask, value)
    }

    func mixBlendMode(_ value: CSSValue) -> some Markup {
        css(.mixBlendMode, value)
    }

    func objectFit(_ value: CSSValue) -> some Markup {
        css(.objectFit, value)
    }

    func objectPosition(_ value: CSSValue) -> some Markup {
        css(.objectPosition, value)
    }

    func opacity(_ value: CSSValue) -> some Markup {
        css(.opacity, value)
    }

    func perspective(_ value: CSSValue) -> some Markup {
        css(.perspective, value)
    }

    func perspectiveOrigin(_ value: CSSValue) -> some Markup {
        css(.perspectiveOrigin, value)
    }

    func rotate(_ value: CSSValue) -> some Markup {
        css(.rotate, value)
    }

    func scale(_ value: CSSValue) -> some Markup {
        css(.scale, value)
    }

    func shapeImageThreshold(_ value: CSSValue) -> some Markup {
        css(.shapeImageThreshold, value)
    }

    func shapeMargin(_ value: CSSValue) -> some Markup {
        css(.shapeMargin, value)
    }

    func shapeOutside(_ value: CSSValue) -> some Markup {
        css(.shapeOutside, value)
    }

    func transform(_ value: CSSValue) -> some Markup {
        css(.transform, value)
    }

    func transformOrigin(_ value: CSSValue) -> some Markup {
        css(.transformOrigin, value)
    }

    func transformStyle(_ value: CSSValue) -> some Markup {
        css(.transformStyle, value)
    }

    func translate(_ value: CSSValue) -> some Markup {
        css(.translate, value)
    }

}

public extension VariantScope {
    func backdropFilter(_ value: CSSValue) {
        css(.backdropFilter, value)
    }

    func clipPath(_ value: CSSValue) {
        css(.clipPath, value)
    }

    func filter(_ value: CSSValue) {
        css(.filter, value)
    }

    func mask(_ value: CSSValue) {
        css(.mask, value)
    }

    func mixBlendMode(_ value: CSSValue) {
        css(.mixBlendMode, value)
    }

    func objectFit(_ value: CSSValue) {
        css(.objectFit, value)
    }

    func objectPosition(_ value: CSSValue) {
        css(.objectPosition, value)
    }

    func opacity(_ value: CSSValue) {
        css(.opacity, value)
    }

    func perspective(_ value: CSSValue) {
        css(.perspective, value)
    }

    func perspectiveOrigin(_ value: CSSValue) {
        css(.perspectiveOrigin, value)
    }

    func rotate(_ value: CSSValue) {
        css(.rotate, value)
    }

    func scale(_ value: CSSValue) {
        css(.scale, value)
    }

    func shapeImageThreshold(_ value: CSSValue) {
        css(.shapeImageThreshold, value)
    }

    func shapeMargin(_ value: CSSValue) {
        css(.shapeMargin, value)
    }

    func shapeOutside(_ value: CSSValue) {
        css(.shapeOutside, value)
    }

    func transform(_ value: CSSValue) {
        css(.transform, value)
    }

    func transformOrigin(_ value: CSSValue) {
        css(.transformOrigin, value)
    }

    func transformStyle(_ value: CSSValue) {
        css(.transformStyle, value)
    }

    func translate(_ value: CSSValue) {
        css(.translate, value)
    }

}
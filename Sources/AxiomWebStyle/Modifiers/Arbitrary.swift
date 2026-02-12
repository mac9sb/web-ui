import Foundation
import AxiomWebUI

public extension Markup {
    func css(_ property: CSSProperty, _ value: CSSValue) -> some Markup {
        modifier(ArbitraryStyleRegistry.className(property: property, value: value))
    }
}

public extension VariantScope {
    func css(_ property: CSSProperty, _ value: CSSValue) {
        addClass(ArbitraryStyleRegistry.className(property: property, value: value))
    }
}

import Foundation
import AxiomWebUI

public extension StartingStyleDeclaration {
    static func property(_ property: CSSProperty, _ value: CSSValue) -> StartingStyleDeclaration {
        StartingStyleDeclaration(property, value)
    }
}

public extension Markup {
    func startingStyle(_ declarations: StartingStyleDeclaration...) -> some Markup {
        modifier(StartingStyleRegistry.className(declarations: declarations))
    }
}

public extension VariantScope {
    func startingStyle(_ declarations: StartingStyleDeclaration...) {
        addClass(StartingStyleRegistry.className(declarations: declarations))
    }
}

import Foundation
import AxiomWebUI

public extension Markup {
    func background(color: ColorToken) -> some Markup {
        if case let .custom(name, cssValue) = color {
            ColorRegistry.register(name: name, cssValue: cssValue)
        }
        return modifier("bg-\(color.classFragment)")
    }

    func border(of width: Int = 1, color: ColorToken) -> some Markup {
        if case let .custom(name, cssValue) = color {
            ColorRegistry.register(name: name, cssValue: cssValue)
        }
        return modifiers(["border-\(max(1, width))", "border-\(color.classFragment)"])
    }
}

public extension VariantScope {
    func background(color: ColorToken) {
        if case let .custom(name, cssValue) = color {
            ColorRegistry.register(name: name, cssValue: cssValue)
        }
        addClass("bg-\(color.classFragment)")
    }

    func border(width: Int, color: ColorToken) {
        if case let .custom(name, cssValue) = color {
            ColorRegistry.register(name: name, cssValue: cssValue)
        }
        addClass("border-\(width)")
        addClass("border-\(color.classFragment)")
    }
}

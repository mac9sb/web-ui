import Foundation
import AxiomWebUI

public extension Markup {
    func font(size: FontSize? = nil, weight: FontWeight? = nil, color: ColorToken? = nil) -> some Markup {
        var classes: [String] = []
        if let size { classes.append("text-\(size.rawValue)") }
        if let weight { classes.append("font-\(weight.rawValue)") }
        if let color {
            if case let .custom(name, cssValue) = color {
                ColorRegistry.register(name: name, cssValue: cssValue)
            }
            classes.append("text-\(color.classFragment)")
        }
        return modifiers(classes)
    }
}

public extension VariantScope {
    func font(size: FontSize? = nil, weight: FontWeight? = nil, color: ColorToken? = nil) {
        if let size { addClass("text-\(size.rawValue)") }
        if let weight { addClass("font-\(weight.rawValue)") }
        if let color {
            if case let .custom(name, cssValue) = color {
                ColorRegistry.register(name: name, cssValue: cssValue)
            }
            addClass("text-\(color.classFragment)")
        }
    }
}

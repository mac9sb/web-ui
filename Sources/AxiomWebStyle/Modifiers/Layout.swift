import Foundation
import AxiomWebUI

public extension Markup {
    func padding(of scale: SpaceScale, at edge: Edge = .all) -> some Markup {
        modifier(edge == .all ? "p-\(scale.rawValue)" : "p\(edge.rawValue)-\(scale.rawValue)")
    }

    func margins(of scale: SpaceScale, at edge: Edge = .all) -> some Markup {
        modifier(edge == .all ? "m-\(scale.rawValue)" : "m\(edge.rawValue)-\(scale.rawValue)")
    }

    func flex(direction: FlexDirection? = nil, align: FlexAlign? = nil, grow: Bool = false) -> some Markup {
        var classes: [String] = ["flex"]
        if let direction { classes.append("flex-\(direction.rawValue)") }
        if let align {
            switch align {
            case .start: classes.append("items-start")
            case .center: classes.append("items-center")
            case .end: classes.append("items-end")
            }
        }
        if grow { classes.append("grow") }
        return modifiers(classes)
    }

    func position(_ position: PositionType) -> some Markup {
        modifier(position.rawValue)
    }

    func zIndex(_ value: Int) -> some Markup {
        modifier("z-\(value)")
    }

    func frame(width: String? = nil, maxWidth: String? = nil, minHeight: String? = nil) -> some Markup {
        var classes: [String] = []
        if let width { classes.append(width == "full" ? "w-full" : "w-[\(width)]") }
        if let maxWidth { classes.append("max-w-[\(maxWidth)]") }
        if let minHeight {
            classes.append(minHeight == "dvh" ? "min-h-dvh" : "min-h-[\(minHeight)]")
        }
        return modifiers(classes)
    }
}

public extension VariantScope {
    func padding(of scale: SpaceScale, at edge: Edge = .all) {
        addClass(edge == .all ? "p-\(scale.rawValue)" : "p\(edge.rawValue)-\(scale.rawValue)")
    }

    func margins(of scale: SpaceScale, at edge: Edge = .all) {
        addClass(edge == .all ? "m-\(scale.rawValue)" : "m\(edge.rawValue)-\(scale.rawValue)")
    }
}

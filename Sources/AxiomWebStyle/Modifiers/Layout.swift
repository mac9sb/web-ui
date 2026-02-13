import Foundation
import AxiomWebUI

private enum LayoutModifierClasses {
    static func padding(of scale: SpaceScale, at edge: Edge) -> String {
        edge == .all ? "p-\(scale.rawValue)" : "p\(edge.rawValue)-\(scale.rawValue)"
    }

    static func margins(of scale: SpaceScale, at edge: Edge) -> String {
        edge == .all ? "m-\(scale.rawValue)" : "m\(edge.rawValue)-\(scale.rawValue)"
    }

    static func flex(
        direction: FlexDirection?,
        inline: Bool,
        align: FlexAlign?,
        justify: FlexJustify?,
        gap: CSSValue?,
        grow: Bool
    ) -> [String] {
        var classes: [String] = [inline ? "inline-flex" : "flex"]
        if let direction { classes.append("flex-\(direction.rawValue)") }
        if let align { classes.append(alignClass(for: align)) }
        if let justify { classes.append(justifyClass(for: justify)) }
        if let gap {
            classes.append(ArbitraryStyleRegistry.className(property: .gap, value: gap))
        }
        if grow { classes.append("grow") }
        return classes
    }

    static func grid(
        columns: CSSValue?,
        rows: CSSValue?,
        autoFlow: CSSValue?,
        align: FlexAlign?,
        justify: FlexJustify?,
        gap: CSSValue?
    ) -> [String] {
        var classes: [String] = ["grid"]
        if let columns {
            classes.append(ArbitraryStyleRegistry.className(property: .gridTemplateColumns, value: columns))
        }
        if let rows {
            classes.append(ArbitraryStyleRegistry.className(property: .gridTemplateRows, value: rows))
        }
        if let autoFlow {
            classes.append(ArbitraryStyleRegistry.className(property: .gridAutoFlow, value: autoFlow))
        }
        if let align { classes.append(alignClass(for: align)) }
        if let justify { classes.append(justifyClass(for: justify)) }
        if let gap {
            classes.append(ArbitraryStyleRegistry.className(property: .gap, value: gap))
        }
        return classes
    }

    static func frame(width: String?, maxWidth: String?, minHeight: String?) -> [String] {
        var classes: [String] = []
        if let width { classes.append(width == "full" ? "w-full" : "w-[\(width)]") }
        if let maxWidth { classes.append("max-w-[\(maxWidth)]") }
        if let minHeight {
            classes.append(minHeight == "dvh" ? "min-h-dvh" : "min-h-[\(minHeight)]")
        }
        return classes
    }

    private static func alignClass(for align: FlexAlign) -> String {
        switch align {
        case .start:
            return "items-start"
        case .center:
            return "items-center"
        case .end:
            return "items-end"
        }
    }

    private static func justifyClass(for justify: FlexJustify) -> String {
        switch justify {
        case .start:
            return "justify-start"
        case .center:
            return "justify-center"
        case .end:
            return "justify-end"
        case .between:
            return "justify-between"
        case .around:
            return "justify-around"
        case .evenly:
            return "justify-evenly"
        }
    }
}

public extension Markup {
    func padding(of scale: SpaceScale, at edge: Edge = .all) -> some Markup {
        modifier(LayoutModifierClasses.padding(of: scale, at: edge))
    }

    func margins(of scale: SpaceScale, at edge: Edge = .all) -> some Markup {
        modifier(LayoutModifierClasses.margins(of: scale, at: edge))
    }

    func flex(
        direction: FlexDirection? = nil,
        inline: Bool = false,
        align: FlexAlign? = nil,
        justify: FlexJustify? = nil,
        gap: CSSValue? = nil,
        grow: Bool = false
    ) -> some Markup {
        modifiers(
            LayoutModifierClasses.flex(
                direction: direction,
                inline: inline,
                align: align,
                justify: justify,
                gap: gap,
                grow: grow
            )
        )
    }

    func grid(
        columns: CSSValue? = nil,
        rows: CSSValue? = nil,
        autoFlow: CSSValue? = nil,
        align: FlexAlign? = nil,
        justify: FlexJustify? = nil,
        gap: CSSValue? = nil
    ) -> some Markup {
        modifiers(
            LayoutModifierClasses.grid(
                columns: columns,
                rows: rows,
                autoFlow: autoFlow,
                align: align,
                justify: justify,
                gap: gap
            )
        )
    }

    func position(_ position: PositionType) -> some Markup {
        modifier(position.rawValue)
    }

    func zIndex(_ value: Int) -> some Markup {
        modifier("z-\(value)")
    }

    func frame(width: String? = nil, maxWidth: String? = nil, minHeight: String? = nil) -> some Markup {
        modifiers(LayoutModifierClasses.frame(width: width, maxWidth: maxWidth, minHeight: minHeight))
    }
}

public extension VariantScope {
    func padding(of scale: SpaceScale, at edge: Edge = .all) {
        addClass(LayoutModifierClasses.padding(of: scale, at: edge))
    }

    func margins(of scale: SpaceScale, at edge: Edge = .all) {
        addClass(LayoutModifierClasses.margins(of: scale, at: edge))
    }

    func flex(
        direction: FlexDirection? = nil,
        inline: Bool = false,
        align: FlexAlign? = nil,
        justify: FlexJustify? = nil,
        gap: CSSValue? = nil,
        grow: Bool = false
    ) {
        for className in LayoutModifierClasses.flex(
            direction: direction,
            inline: inline,
            align: align,
            justify: justify,
            gap: gap,
            grow: grow
        ) {
            addClass(className)
        }
    }

    func grid(
        columns: CSSValue? = nil,
        rows: CSSValue? = nil,
        autoFlow: CSSValue? = nil,
        align: FlexAlign? = nil,
        justify: FlexJustify? = nil,
        gap: CSSValue? = nil
    ) {
        for className in LayoutModifierClasses.grid(
            columns: columns,
            rows: rows,
            autoFlow: autoFlow,
            align: align,
            justify: justify,
            gap: gap
        ) {
            addClass(className)
        }
    }
}

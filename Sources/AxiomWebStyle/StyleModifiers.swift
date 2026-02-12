import Foundation
import AxiomWebUI
import AxiomWebI18n

/// Standard design-system color shades modeled after common utility-scale palettes.
public enum ColorShade: Int, Sendable, CaseIterable {
    case _50 = 50
    case _100 = 100
    case _200 = 200
    case _300 = 300
    case _400 = 400
    case _500 = 500
    case _600 = 600
    case _700 = 700
    case _800 = 800
    case _900 = 900
    case _950 = 950
}

public enum ColorToken: Sendable, Equatable {
    // Neutrals
    case slate(Int)
    case stone(Int)
    case gray(Int)
    case zinc(Int)
    case neutral(Int)

    // Colors
    case red(Int)
    case orange(Int)
    case amber(Int)
    case yellow(Int)
    case lime(Int)
    case green(Int)
    case emerald(Int)
    case teal(Int)
    case cyan(Int)
    case sky(Int)
    case blue(Int)
    case indigo(Int)
    case violet(Int)
    case purple(Int)
    case fuchsia(Int)
    case pink(Int)
    case rose(Int)

    // Base tokens
    case transparent
    case current
    case inherit
    case black
    case white

    // Explicit custom mapping (class name + css value)
    case custom(name: String, cssValue: String)

    var classFragment: String {
        switch self {
        case .slate(let shade): return "slate-\(shade)"
        case .stone(let shade): return "stone-\(shade)"
        case .gray(let shade): return "gray-\(shade)"
        case .zinc(let shade): return "zinc-\(shade)"
        case .neutral(let shade): return "neutral-\(shade)"
        case .red(let shade): return "red-\(shade)"
        case .orange(let shade): return "orange-\(shade)"
        case .amber(let shade): return "amber-\(shade)"
        case .yellow(let shade): return "yellow-\(shade)"
        case .lime(let shade): return "lime-\(shade)"
        case .green(let shade): return "green-\(shade)"
        case .emerald(let shade): return "emerald-\(shade)"
        case .teal(let shade): return "teal-\(shade)"
        case .cyan(let shade): return "cyan-\(shade)"
        case .sky(let shade): return "sky-\(shade)"
        case .blue(let shade): return "blue-\(shade)"
        case .indigo(let shade): return "indigo-\(shade)"
        case .violet(let shade): return "violet-\(shade)"
        case .purple(let shade): return "purple-\(shade)"
        case .fuchsia(let shade): return "fuchsia-\(shade)"
        case .pink(let shade): return "pink-\(shade)"
        case .rose(let shade): return "rose-\(shade)"
        case .transparent: return "transparent"
        case .current: return "current"
        case .inherit: return "inherit"
        case .black: return "black"
        case .white: return "white"
        case .custom(let name, _): return name
        }
    }
}

public enum SpaceScale: Int, Sendable {
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case eight = 8
    case ten = 10
}

public enum Edge: String, Sendable {
    case all = ""
    case horizontal = "x"
    case vertical = "y"
    case top = "t"
    case right = "r"
    case bottom = "b"
    case left = "l"
}

public enum FontSize: String, Sendable {
    case sm
    case base
    case lg
    case xl
    case xl2 = "2xl"
    case xl3 = "3xl"
}

public enum FontWeight: String, Sendable {
    case normal
    case medium
    case semibold
    case bold
}

public enum FlexDirection: String, Sendable {
    case row
    case column = "col"
}

public enum FlexAlign: String, Sendable {
    case start
    case center
    case end
}

public enum PositionType: String, Sendable {
    case relative
    case absolute
    case fixed
    case sticky
}

public struct StyledMarkup<Content: Markup>: Markup {
    let content: Content
    let classes: [String]

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        content.makeNodes(locale: locale).map { node in
            classes.reduce(node) { partial, cssClass in
                partial.addingAttribute(HTMLAttribute("class", cssClass))
            }
        }
    }
}

public extension Markup {
    func modifier(_ className: String) -> some Markup {
        StyledMarkup(content: self, classes: [className])
    }

    func modifiers(_ classNames: [String]) -> some Markup {
        StyledMarkup(content: self, classes: classNames)
    }

    func padding(of scale: SpaceScale, at edge: Edge = .all) -> some Markup {
        modifier(edge == .all ? "p-\(scale.rawValue)" : "p\(edge.rawValue)-\(scale.rawValue)")
    }

    func margins(of scale: SpaceScale, at edge: Edge = .all) -> some Markup {
        modifier(edge == .all ? "m-\(scale.rawValue)" : "m\(edge.rawValue)-\(scale.rawValue)")
    }

    func background(color: ColorToken) -> some Markup {
        if case let .custom(name, cssValue) = color {
            ColorRegistry.register(name: name, cssValue: cssValue)
        }
        return modifier("bg-\(color.classFragment)")
    }

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

    func shadow(_ name: String = "md") -> some Markup {
        modifier("shadow-\(name)")
    }

    func on(_ content: (VariantBuilder) -> Void) -> some Markup {
        let builder = VariantBuilder()
        content(builder)
        return modifiers(builder.classes)
    }
}

public final class VariantBuilder {
    fileprivate var classes: [String] = []

    public init() {}

    public func dark(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: ["dark"], builder: self))
    }

    public func sm(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: ["sm"], builder: self))
    }

    public func md(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: ["md"], builder: self))
    }

    public func lg(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: ["lg"], builder: self))
    }
}

public struct VariantScope {
    let prefixes: [String]
    let builder: VariantBuilder

    init(prefixes: [String], builder: VariantBuilder) {
        self.prefixes = prefixes
        self.builder = builder
    }

    private func push(_ rawClass: String) {
        builder.classes.append((prefixes + [rawClass]).joined(separator: ":"))
    }

    public func background(color: ColorToken) {
        if case let .custom(name, cssValue) = color {
            ColorRegistry.register(name: name, cssValue: cssValue)
        }
        push("bg-\(color.classFragment)")
    }

    public func border(width: Int, color: ColorToken) {
        if case let .custom(name, cssValue) = color {
            ColorRegistry.register(name: name, cssValue: cssValue)
        }
        push("border-\(width)")
        push("border-\(color.classFragment)")
    }

    public func font(size: FontSize? = nil, weight: FontWeight? = nil, color: ColorToken? = nil) {
        if let size { push("text-\(size.rawValue)") }
        if let weight { push("font-\(weight.rawValue)") }
        if let color {
            if case let .custom(name, cssValue) = color {
                ColorRegistry.register(name: name, cssValue: cssValue)
            }
            push("text-\(color.classFragment)")
        }
    }

    public func padding(of scale: SpaceScale, at edge: Edge = .all) {
        push(edge == .all ? "p-\(scale.rawValue)" : "p\(edge.rawValue)-\(scale.rawValue)")
    }

    public func margins(of scale: SpaceScale, at edge: Edge = .all) {
        push(edge == .all ? "m-\(scale.rawValue)" : "m\(edge.rawValue)-\(scale.rawValue)")
    }
}

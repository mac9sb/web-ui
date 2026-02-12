import Foundation

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
    case slate(Int)
    case stone(Int)
    case gray(Int)
    case zinc(Int)
    case neutral(Int)

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

    case transparent
    case current
    case inherit
    case black
    case white

    case custom(name: String, cssValue: String)

    public var classFragment: String {
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

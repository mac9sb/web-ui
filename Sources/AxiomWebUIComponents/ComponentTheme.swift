import Foundation
import AxiomWebStyle

public struct ComponentTheme: Sendable, Equatable {
    public var surfaceColor: ColorToken
    public var foregroundColor: ColorToken
    public var mutedColor: ColorToken
    public var borderColor: ColorToken
    public var accentColor: ColorToken
    public var destructiveColor: ColorToken
    public var cornerRadius: CSSValue
    public var spacingMultiplier: Double

    public init(
        surfaceColor: ColorToken = .white,
        foregroundColor: ColorToken = .stone(900),
        mutedColor: ColorToken = .stone(600),
        borderColor: ColorToken = .stone(200),
        accentColor: ColorToken = .blue(600),
        destructiveColor: ColorToken = .red(600),
        cornerRadius: CSSValue = .length(0.75, .rem),
        spacingMultiplier: Double = 1.0
    ) {
        self.surfaceColor = surfaceColor
        self.foregroundColor = foregroundColor
        self.mutedColor = mutedColor
        self.borderColor = borderColor
        self.accentColor = accentColor
        self.destructiveColor = destructiveColor
        self.cornerRadius = cornerRadius
        self.spacingMultiplier = max(0.25, spacingMultiplier)
    }

    public static let `default` = ComponentTheme()
}

public enum ComponentThemeStore {
    private static let lock = NSLock()
    private static nonisolated(unsafe) var currentTheme: ComponentTheme = .default

    public static var current: ComponentTheme {
        lock.lock()
        defer { lock.unlock() }
        return currentTheme
    }

    public static func set(_ theme: ComponentTheme) {
        lock.lock()
        defer { lock.unlock() }
        currentTheme = theme
    }

    public static func reset() {
        set(.default)
    }
}

public extension ComponentTheme {
    func spacing(_ units: Int) -> CSSValue {
        .raw("calc(var(--space-unit) * \(Double(units) * spacingMultiplier))")
    }
}

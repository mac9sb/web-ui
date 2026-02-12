import Foundation

public enum ViewTransitionNavigation: String, Sendable, Equatable {
    case auto
    case none
}

public enum ViewTransitionTiming: String, Sendable, Equatable {
    case linear
    case ease
    case easeIn = "ease-in"
    case easeOut = "ease-out"
    case easeInOut = "ease-in-out"
}

public enum ViewTransitionFillMode: String, Sendable, Equatable {
    case none
    case forwards
    case backwards
    case both
}

public struct ViewTransitionConfiguration: Sendable, Equatable {
    public var enabled: Bool
    public var navigation: ViewTransitionNavigation
    public var runtimeNavigation: Bool
    public var applyRootAnimation: Bool
    public var durationSeconds: Double
    public var delaySeconds: Double
    public var timing: ViewTransitionTiming
    public var fillMode: ViewTransitionFillMode
    public var respectReducedMotion: Bool

    public init(
        enabled: Bool = true,
        navigation: ViewTransitionNavigation = .auto,
        runtimeNavigation: Bool = true,
        applyRootAnimation: Bool = true,
        durationSeconds: Double = 0.35,
        delaySeconds: Double = 0,
        timing: ViewTransitionTiming = .ease,
        fillMode: ViewTransitionFillMode = .both,
        respectReducedMotion: Bool = true
    ) {
        self.enabled = enabled
        self.navigation = navigation
        self.runtimeNavigation = runtimeNavigation
        self.applyRootAnimation = applyRootAnimation
        self.durationSeconds = max(0, durationSeconds)
        self.delaySeconds = max(0, delaySeconds)
        self.timing = timing
        self.fillMode = fillMode
        self.respectReducedMotion = respectReducedMotion
    }

    public init(
        from base: ViewTransitionConfiguration,
        enabled: Bool? = nil,
        navigation: ViewTransitionNavigation? = nil,
        runtimeNavigation: Bool? = nil,
        applyRootAnimation: Bool? = nil,
        durationSeconds: Double? = nil,
        delaySeconds: Double? = nil,
        timing: ViewTransitionTiming? = nil,
        fillMode: ViewTransitionFillMode? = nil,
        respectReducedMotion: Bool? = nil
    ) {
        self.init(
            enabled: enabled ?? base.enabled,
            navigation: navigation ?? base.navigation,
            runtimeNavigation: runtimeNavigation ?? base.runtimeNavigation,
            applyRootAnimation: applyRootAnimation ?? base.applyRootAnimation,
            durationSeconds: durationSeconds ?? base.durationSeconds,
            delaySeconds: delaySeconds ?? base.delaySeconds,
            timing: timing ?? base.timing,
            fillMode: fillMode ?? base.fillMode,
            respectReducedMotion: respectReducedMotion ?? base.respectReducedMotion
        )
    }
}

public protocol ViewTransitionProviding {
    var viewTransition: ViewTransitionConfiguration { get }
}


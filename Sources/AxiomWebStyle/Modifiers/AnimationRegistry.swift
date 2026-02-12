import Foundation

public enum AnimationTiming: String, Sendable {
    case linear
    case ease
    case easeIn = "ease-in"
    case easeOut = "ease-out"
    case easeInOut = "ease-in-out"
}

public enum AnimationDirection: String, Sendable {
    case normal
    case reverse
    case alternate
    case alternateReverse = "alternate-reverse"
}

public enum AnimationFillMode: String, Sendable {
    case none
    case forwards
    case backwards
    case both
}

public enum AnimationPlayState: String, Sendable {
    case running
    case paused
}

public enum AnimationStartingStylePolicy: Sendable {
    case automatic
    case disabled
}

public enum AnimationIteration: Sendable {
    case count(Int)
    case infinite

    var cssValue: String {
        switch self {
        case .count(let value): return String(max(1, value))
        case .infinite: return "infinite"
        }
    }
}

public struct AnimationFrame: Sendable {
    public enum Selector: Sendable {
        case from
        case to
        case percent(Int)

        var cssValue: String {
            switch self {
            case .from: return "from"
            case .to: return "to"
            case .percent(let value): return "\(max(0, min(100, value)))%"
            }
        }
    }

    public struct Declaration: Sendable {
        public let property: CSSProperty
        public let value: CSSValue

        public init(property: CSSProperty, value: CSSValue) {
            self.property = property
            self.value = value
        }
    }

    public let selector: Selector
    public let declarations: [Declaration]

    public init(selector: Selector, declarations: [Declaration]) {
        self.selector = selector
        self.declarations = declarations
    }
}

public enum AnimationName: Sendable {
    case fadeIn
    case slideUp
    case pulse
    case spin
    case bounce
    case custom(name: String, frames: [AnimationFrame])
}

public struct AnimationSpec: Sendable {
    public let name: AnimationName
    public let durationSeconds: Double
    public let timing: AnimationTiming
    public let delaySeconds: Double
    public let iteration: AnimationIteration
    public let direction: AnimationDirection
    public let fillMode: AnimationFillMode
    public let playState: AnimationPlayState
    public let startingStyle: AnimationStartingStylePolicy

    public init(
        name: AnimationName,
        durationSeconds: Double = 0.3,
        timing: AnimationTiming = .ease,
        delaySeconds: Double = 0,
        iteration: AnimationIteration = .count(1),
        direction: AnimationDirection = .normal,
        fillMode: AnimationFillMode = .both,
        playState: AnimationPlayState = .running,
        startingStyle: AnimationStartingStylePolicy = .automatic
    ) {
        self.name = name
        self.durationSeconds = max(0.01, durationSeconds)
        self.timing = timing
        self.delaySeconds = max(0, delaySeconds)
        self.iteration = iteration
        self.direction = direction
        self.fillMode = fillMode
        self.playState = playState
        self.startingStyle = startingStyle
    }

    public init(
        name: AnimationName,
        duration: Double = 0.3,
        timing: AnimationTiming = .ease,
        delay: Double = 0,
        iteration: AnimationIteration = .count(1),
        direction: AnimationDirection = .normal,
        fillMode: AnimationFillMode = .both,
        playState: AnimationPlayState = .running,
        startingStyle: AnimationStartingStylePolicy = .automatic
    ) {
        self.init(
            name: name,
            durationSeconds: duration,
            timing: timing,
            delaySeconds: delay,
            iteration: iteration,
            direction: direction,
            fillMode: fillMode,
            playState: playState,
            startingStyle: startingStyle
        )
    }
}

public enum AnimationRegistry {
    private static let lock = NSLock()
    private static nonisolated(unsafe) var customKeyframesByName: [String: String] = [:]

    public static func resolveName(_ name: AnimationName) -> String {
        switch name {
        case .fadeIn:
            return "ax-fade-in"
        case .slideUp:
            return "ax-slide-up"
        case .pulse:
            return "ax-pulse"
        case .spin:
            return "ax-spin"
        case .bounce:
            return "ax-bounce"
        case .custom(let name, let frames):
            let sanitized = sanitizeName(name)
            registerCustomKeyframes(name: sanitized, frames: frames)
            return sanitized
        }
    }

    public static func keyframeCSS() -> String {
        lock.lock()
        let custom = customKeyframesByName
        lock.unlock()

        var blocks: [String] = builtinKeyframes.values.sorted()
        blocks.append(contentsOf: custom.keys.sorted().compactMap { custom[$0] })
        return blocks.joined(separator: "")
    }

    private static func registerCustomKeyframes(name: String, frames: [AnimationFrame]) {
        let css = keyframes(name: name, frames: frames)
        lock.lock()
        customKeyframesByName[name] = css
        lock.unlock()
    }

    private static func keyframes(name: String, frames: [AnimationFrame]) -> String {
        let body = frames
            .map { frame in
                let declarations = frame.declarations
                    .map { "\($0.property.rawValue):\($0.value.rawValue)" }
                    .joined(separator: ";")
                return "\(frame.selector.cssValue){\(declarations)}"
            }
            .joined()
        return "@keyframes \(name){\(body)}"
    }

    private static func sanitizeName(_ value: String) -> String {
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_")
        let cleaned = String(value.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" })
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        if cleaned.isEmpty {
            return "ax-custom-animation"
        }
        if cleaned.hasPrefix("ax-") {
            return cleaned
        }
        return "ax-\(cleaned)"
    }

    private static let builtinKeyframes: [String: String] = [
        "ax-fade-in": "@keyframes ax-fade-in{from{opacity:0}to{opacity:1}}",
        "ax-slide-up": "@keyframes ax-slide-up{from{opacity:0;transform:translateY(0.5rem)}to{opacity:1;transform:translateY(0)}}",
        "ax-pulse": "@keyframes ax-pulse{0%{opacity:1}50%{opacity:0.5}100%{opacity:1}}",
        "ax-spin": "@keyframes ax-spin{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}",
        "ax-bounce": "@keyframes ax-bounce{0%,100%{transform:translateY(-8%);animation-timing-function:cubic-bezier(0.8,0,1,1)}50%{transform:translateY(0);animation-timing-function:cubic-bezier(0,0,0.2,1)}}",
    ]
}

public extension AnimationSpec {
    func toCSSValue() -> CSSValue {
        let nameValue = AnimationRegistry.resolveName(name)
        let duration = formatSeconds(durationSeconds)
        let delay = formatSeconds(delaySeconds)
        let shorthand = [
            nameValue,
            duration,
            timing.rawValue,
            delay,
            iteration.cssValue,
            direction.rawValue,
            fillMode.rawValue,
            playState.rawValue,
        ].joined(separator: " ")
        return .raw(shorthand)
    }

    private func formatSeconds(_ value: Double) -> String {
        if value.rounded() == value {
            return String(format: "%.0fs", value)
        }
        let normalized = String(format: "%.3f", value)
            .replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
        return "\(normalized)s"
    }

    func inferredStartingStyleDeclarations() -> [StartingStyleDeclaration]? {
        guard startingStyle == .automatic else {
            return nil
        }

        switch name {
        case .fadeIn:
            return [StartingStyleDeclaration(.opacity, .number(0))]
        case .slideUp:
            return [
                StartingStyleDeclaration(.opacity, .number(0)),
                StartingStyleDeclaration(.transform, .raw("translateY(0.5rem)")),
            ]
        case .pulse:
            return [StartingStyleDeclaration(.opacity, .number(1))]
        case .spin:
            return [StartingStyleDeclaration(.transform, .raw("rotate(0deg)"))]
        case .bounce:
            return [StartingStyleDeclaration(.transform, .raw("translateY(-8%)"))]
        case .custom(_, let frames):
            guard let frame = initialFrame(from: frames) else {
                return nil
            }
            let declarations = frame.declarations.map {
                StartingStyleDeclaration($0.property, $0.value)
            }
            return declarations.isEmpty ? nil : declarations
        }
    }

    private func initialFrame(from frames: [AnimationFrame]) -> AnimationFrame? {
        if let explicitFrom = frames.first(where: { $0.selector.isFrom }) {
            return explicitFrom
        }

        let sortedPercentFrames = frames
            .compactMap { frame in
                frame.selector.percentValue.map { (percent: $0, frame: frame) }
            }
            .sorted { $0.percent < $1.percent }
        if let firstPercent = sortedPercentFrames.first {
            return firstPercent.frame
        }

        if let toFrame = frames.first(where: { $0.selector.isTo }) {
            return toFrame
        }

        return frames.first
    }
}

private extension AnimationFrame.Selector {
    var isFrom: Bool {
        if case .from = self {
            return true
        }
        return false
    }

    var isTo: Bool {
        if case .to = self {
            return true
        }
        return false
    }

    var percentValue: Int? {
        if case .percent(let value) = self {
            return max(0, min(100, value))
        }
        return nil
    }
}

import Foundation
import AxiomWebUI

public struct RuntimeStateDefinition: Sendable, Equatable {
    public let key: String
    public let initialValue: RuntimePrimitive

    public init(key: String, initialValue: RuntimePrimitive) {
        self.key = key
        self.initialValue = initialValue
    }
}

public enum RuntimePrimitive: Sendable, Equatable {
    case string(String)
    case int(Int)
    case bool(Bool)

    var js: String {
        switch self {
        case .string(let value):
            return "\"\(value.replacingOccurrences(of: "\"", with: "\\\""))\""
        case .int(let value):
            return "\(value)"
        case .bool(let value):
            return value ? "true" : "false"
        }
    }
}

public enum RuntimeEventType: String, Sendable {
    case click
    case input
    case change
    case submit
}

public enum RuntimeAction: Sendable, Equatable {
    case set(key: String, value: RuntimePrimitive)
    case increment(key: String, by: Int)
    case decrement(key: String, by: Int)
    case toggle(key: String)
    case navigate(path: String)
}

public struct RuntimeEventBinding: Sendable, Equatable {
    public let elementID: String
    public let event: RuntimeEventType
    public let action: RuntimeAction

    public init(elementID: String, event: RuntimeEventType, action: RuntimeAction) {
        self.elementID = elementID
        self.event = event
        self.action = action
    }
}

public struct RuntimeTimer: Sendable, Equatable {
    public enum Kind: Sendable, Equatable {
        case timeout(seconds: Int)
        case interval(seconds: Int)
    }

    public let action: RuntimeAction
    public let kind: Kind

    public init(action: RuntimeAction, kind: Kind) {
        self.action = action
        self.kind = kind
    }
}

public struct RuntimeProgram: Sendable, Equatable {
    public var states: [RuntimeStateDefinition]
    public var events: [RuntimeEventBinding]
    public var timers: [RuntimeTimer]

    public init(states: [RuntimeStateDefinition] = [], events: [RuntimeEventBinding] = [], timers: [RuntimeTimer] = []) {
        self.states = states
        self.events = events
        self.timers = timers
    }

    public var isEmpty: Bool {
        states.isEmpty && events.isEmpty && timers.isEmpty
    }
}

public enum RuntimeJavaScriptGenerator {
    public static func generate(program: RuntimeProgram) -> String {
        let initialState = program.states
            .map { "\($0.key): \($0.initialValue.js)" }
            .joined(separator: ",")

        let eventBindings = program.events.map { binding in
            let action = actionScript(binding.action)
            return "document.getElementById(\"\(binding.elementID)\")?.addEventListener(\"\(binding.event.rawValue)\", function(event){\(action)});"
        }.joined(separator: "")

        let timerBindings = program.timers.map { timer -> String in
            let action = actionScript(timer.action)
            switch timer.kind {
            case .timeout(let seconds):
                return "setTimeout(function(){\(action)}, \(seconds * 1000));"
            case .interval(let seconds):
                return "setInterval(function(){\(action)}, \(seconds * 1000));"
            }
        }.joined(separator: "")

        return "(function(){const state={\(initialState)};window.__ax_state=state;\(eventBindings)\(timerBindings)})();"
    }

    private static func actionScript(_ action: RuntimeAction) -> String {
        switch action {
        case .set(let key, let value):
            return "state[\"\(key)\"]=\(value.js);"
        case .increment(let key, let by):
            return "state[\"\(key)\"]=(state[\"\(key)\"]||0)+\(by);"
        case .decrement(let key, let by):
            return "state[\"\(key)\"]=(state[\"\(key)\"]||0)-\(by);"
        case .toggle(let key):
            return "state[\"\(key)\"]=!state[\"\(key)\"];"
        case .navigate(let path):
            return "window.location.href=\"\(path.replacingOccurrences(of: "\"", with: "\\\""))\";"
        }
    }
}

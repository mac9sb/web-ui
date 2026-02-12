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

public protocol RuntimePrimitiveConvertible: Sendable {
    var runtimePrimitive: RuntimePrimitive { get }
}

extension String: RuntimePrimitiveConvertible {
    public var runtimePrimitive: RuntimePrimitive { .string(self) }
}

extension Int: RuntimePrimitiveConvertible {
    public var runtimePrimitive: RuntimePrimitive { .int(self) }
}

extension Bool: RuntimePrimitiveConvertible {
    public var runtimePrimitive: RuntimePrimitive { .bool(self) }
}

public extension RuntimePrimitive {
    init<T: RuntimePrimitiveConvertible>(_ value: T) {
        self = value.runtimePrimitive
    }
}

public enum RuntimeEventType: String, Sendable, CaseIterable {
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
    case invokeWasm(canvasID: String, export: String, payload: WasmValue)
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

public enum RuntimeDirective: Sendable, Equatable {
    case state(RuntimeStateDefinition)
    case event(RuntimeEventBinding)
    case timer(RuntimeTimer)
}

@resultBuilder
public enum RuntimeBuilder {
    public static func buildBlock(_ components: [RuntimeDirective]...) -> [RuntimeDirective] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [RuntimeDirective]?) -> [RuntimeDirective] {
        component ?? []
    }

    public static func buildEither(first component: [RuntimeDirective]) -> [RuntimeDirective] {
        component
    }

    public static func buildEither(second component: [RuntimeDirective]) -> [RuntimeDirective] {
        component
    }

    public static func buildArray(_ components: [[RuntimeDirective]]) -> [RuntimeDirective] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: RuntimeDirective) -> [RuntimeDirective] {
        [expression]
    }

    public static func buildExpression(_ expression: [RuntimeDirective]) -> [RuntimeDirective] {
        expression
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

    public init(@RuntimeBuilder _ content: () -> [RuntimeDirective]) {
        var states: [RuntimeStateDefinition] = []
        var events: [RuntimeEventBinding] = []
        var timers: [RuntimeTimer] = []

        for directive in content() {
            switch directive {
            case .state(let state):
                states.append(state)
            case .event(let event):
                events.append(event)
            case .timer(let timer):
                timers.append(timer)
            }
        }

        self.init(states: states, events: events, timers: timers)
    }

    public var isEmpty: Bool {
        states.isEmpty && events.isEmpty && timers.isEmpty
    }

    public func merging(_ overriding: RuntimeProgram) -> RuntimeProgram {
        var order: [String] = []
        var stateValues: [String: RuntimePrimitive] = [:]

        for state in states {
            if stateValues[state.key] == nil {
                order.append(state.key)
            }
            stateValues[state.key] = state.initialValue
        }

        for state in overriding.states {
            if stateValues[state.key] == nil {
                order.append(state.key)
            }
            stateValues[state.key] = state.initialValue
        }

        let mergedStates = order.compactMap { key in
            stateValues[key].map { RuntimeStateDefinition(key: key, initialValue: $0) }
        }

        return RuntimeProgram(
            states: mergedStates,
            events: events + overriding.events,
            timers: timers + overriding.timers
        )
    }
}

public enum Runtime {
    public static func state<Value: RuntimePrimitiveConvertible>(_ projection: State<Value>.Projection) -> RuntimeDirective {
        .state(RuntimeStateDefinition(key: projection.key.rawValue, initialValue: RuntimePrimitive(projection.initialValue)))
    }

    public static func state<Value: RuntimePrimitiveConvertible>(_ key: StateKey<Value>, initial value: Value) -> RuntimeDirective {
        .state(RuntimeStateDefinition(key: key.rawValue, initialValue: RuntimePrimitive(value)))
    }

    public static func on(_ elementID: String, event: RuntimeEventType, perform action: RuntimeAction) -> RuntimeDirective {
        .event(RuntimeEventBinding(elementID: elementID, event: event, action: action))
    }

    public static func after(seconds: Int, perform action: RuntimeAction) -> RuntimeDirective {
        .timer(RuntimeTimer(action: action, kind: .timeout(seconds: max(0, seconds))))
    }

    public static func every(seconds: Int, perform action: RuntimeAction) -> RuntimeDirective {
        .timer(RuntimeTimer(action: action, kind: .interval(seconds: max(1, seconds))))
    }

    public static func set<Value: RuntimePrimitiveConvertible>(_ projection: State<Value>.Projection, to value: Value) -> RuntimeAction {
        .set(key: projection.key.rawValue, value: RuntimePrimitive(value))
    }

    public static func set<Value: RuntimePrimitiveConvertible>(_ key: StateKey<Value>, to value: Value) -> RuntimeAction {
        .set(key: key.rawValue, value: RuntimePrimitive(value))
    }

    public static func increment(_ projection: State<Int>.Projection, by value: Int = 1) -> RuntimeAction {
        .increment(key: projection.key.rawValue, by: value)
    }

    public static func increment(_ key: StateKey<Int>, by value: Int = 1) -> RuntimeAction {
        .increment(key: key.rawValue, by: value)
    }

    public static func decrement(_ projection: State<Int>.Projection, by value: Int = 1) -> RuntimeAction {
        .decrement(key: projection.key.rawValue, by: value)
    }

    public static func decrement(_ key: StateKey<Int>, by value: Int = 1) -> RuntimeAction {
        .decrement(key: key.rawValue, by: value)
    }

    public static func toggle(_ projection: State<Bool>.Projection) -> RuntimeAction {
        .toggle(key: projection.key.rawValue)
    }

    public static func toggle(_ key: StateKey<Bool>) -> RuntimeAction {
        .toggle(key: key.rawValue)
    }

    public static func navigate(to path: String) -> RuntimeAction {
        .navigate(path: path)
    }

    public static func invokeWasm(
        canvasID: String,
        export: String,
        payload: WasmValue = .null
    ) -> RuntimeAction {
        .invokeWasm(canvasID: canvasID, export: export, payload: payload)
    }
}

public protocol RuntimeProgramProviding {
    var runtimeProgram: RuntimeProgram { get }
}

public enum RuntimeDOMCodec {
    public static func eventAttributeName(for event: RuntimeEventType) -> String {
        RuntimeBindingAttributes.event(event.rawValue)
    }

    public static func statesAttributeName() -> String {
        RuntimeBindingAttributes.states
    }

    public static func encodeStates(_ states: [RuntimeStateDefinition]) -> String {
        var valuesByKey: [String: RuntimePrimitive] = [:]
        var order: [String] = []

        for state in states {
            if valuesByKey[state.key] == nil {
                order.append(state.key)
            }
            valuesByKey[state.key] = state.initialValue
        }

        return order.compactMap { key -> String? in
            guard let value = valuesByKey[key] else { return nil }
            let (kind, encoded) = encodePrimitive(value)
            return "\(encodeBase64(key))|\(kind)|\(encoded)"
        }.joined(separator: ",")
    }

    public static func encodeActions(_ actions: [RuntimeAction]) -> String {
        actions.compactMap { action in
            switch action {
            case .set(let key, let value):
                let (kind, encoded) = encodePrimitive(value)
                return "set|\(encodeBase64(key))|\(kind)|\(encoded)"
            case .increment(let key, let by):
                return "inc|\(encodeBase64(key))|\(by)"
            case .decrement(let key, let by):
                return "dec|\(encodeBase64(key))|\(by)"
            case .toggle(let key):
                return "tog|\(encodeBase64(key))"
            case .navigate(let path):
                return "nav|\(encodeBase64(path))"
            case .invokeWasm(let canvasID, let export, let payload):
                return "wasm|\(encodeBase64(canvasID))|\(encodeBase64(export))|\(encodeBase64(payload.jsonString()))"
            }
        }.joined(separator: ",")
    }

    private static func encodePrimitive(_ primitive: RuntimePrimitive) -> (String, String) {
        switch primitive {
        case .string(let value):
            return ("s", encodeBase64(value))
        case .int(let value):
            return ("i", "\(value)")
        case .bool(let value):
            return ("b", value ? "1" : "0")
        }
    }

    private static func encodeBase64(_ value: String) -> String {
        Data(value.utf8).base64EncodedString()
    }
}

public enum RuntimeJavaScriptGenerator {
    public static func generate(program: RuntimeProgram, includeDOMBindings: Bool = false) -> String {
        if program.isEmpty && !includeDOMBindings {
            return ""
        }

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

        let domBindings = includeDOMBindings ? domBindingScript : ""
        return "(function(){const state={\(initialState)};window.__ax_state=state;\(eventBindings)\(timerBindings)\(domBindings)})();"
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
        case .invokeWasm(let canvasID, let export, let payload):
            let encodedCanvasID = canvasID.replacingOccurrences(of: "\"", with: "\\\"")
            let encodedExport = export.replacingOccurrences(of: "\"", with: "\\\"")
            let payloadJSON = payload.jsonString().replacingOccurrences(of: "</script", with: "<\\/script")
            return "if(window.AxiomWasm&&typeof window.AxiomWasm.invoke==='function'){window.AxiomWasm.invoke(\"\(encodedCanvasID)\",\"\(encodedExport)\",\(payloadJSON)).then(function(result){window.__ax_wasm_last=result;}).catch(function(error){window.__ax_wasm_error=String(error);});}"
        }
    }

    private static let domBindingScript = """
const __axB64=function(v){try{const b=atob(v);let r=\"\";for(let i=0;i<b.length;i++){r+=\"%\"+(\"00\"+b.charCodeAt(i).toString(16)).slice(-2);}return decodeURIComponent(r);}catch(e){return\"\";}};const __axPrim=function(t,v){if(t===\"i\"){return parseInt(v,10)||0;}if(t===\"b\"){return v===\"1\";}return __axB64(v);};const __axEnsureState=function(raw){if(!raw){return;}raw.split(\",\").forEach(function(token){if(!token){return;}const parts=token.split(\"|\");if(parts.length<3){return;}const key=__axB64(parts[0]);if(key in state){return;}state[key]=__axPrim(parts[1],parts[2]);});};const __axInvokeWasm=function(canvasID,exportName,payloadRaw){if(!(window.AxiomWasm&&typeof window.AxiomWasm.invoke==='function')){return;}let payload=null;try{payload=JSON.parse(__axB64(payloadRaw||\"\"));}catch(_){payload=null;}window.AxiomWasm.invoke(canvasID,exportName,payload).then(function(result){window.__ax_wasm_last=result;}).catch(function(error){window.__ax_wasm_error=String(error);});};const __axApply=function(token){if(!token){return;}const parts=token.split(\"|\");if(parts.length===0){return;}const type=parts[0];if(type===\"nav\"){window.location.href=__axB64(parts[1]||\"\");return;}if(type===\"wasm\"){__axInvokeWasm(__axB64(parts[1]||\"\"),__axB64(parts[2]||\"\"),parts[3]||\"\");return;}const key=__axB64(parts[1]||\"\");if(!(key in state)){state[key]=0;}if(type===\"set\"){state[key]=__axPrim(parts[2],parts[3]||\"\");return;}if(type===\"inc\"){state[key]=(state[key]||0)+(parseInt(parts[2],10)||0);return;}if(type===\"dec\"){state[key]=(state[key]||0)-(parseInt(parts[2],10)||0);return;}if(type===\"tog\"){state[key]=!state[key];}};const __axEvents=[\"click\",\"input\",\"change\",\"submit\"];const __axSelector=\"[data-ax-states],[data-ax-on-click],[data-ax-on-input],[data-ax-on-change],[data-ax-on-submit]\";document.querySelectorAll(__axSelector).forEach(function(element){__axEnsureState(element.getAttribute(\"data-ax-states\"));__axEvents.forEach(function(eventName){const raw=element.getAttribute(\"data-ax-on-\"+eventName);if(!raw){return;}element.addEventListener(eventName,function(event){if(eventName===\"submit\"){event.preventDefault();}raw.split(\",\").forEach(__axApply);});});});
"""
}

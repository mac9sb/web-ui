import Foundation
import AxiomWebUI

public final class InteractionScope {
    private(set) var states: [RuntimeStateDefinition] = []
    private(set) var actions: [RuntimeAction] = []

    public init() {}

    public func set<Value: RuntimePrimitiveConvertible>(_ projection: State<Value>.Projection, to value: Value) {
        registerState(projection)
        actions.append(.set(key: projection.key.rawValue, value: RuntimePrimitive(value)))
    }

    public func set<Value: RuntimePrimitiveConvertible>(_ key: StateKey<Value>, to value: Value, initial: Value) {
        states.append(RuntimeStateDefinition(key: key.rawValue, initialValue: RuntimePrimitive(initial)))
        actions.append(.set(key: key.rawValue, value: RuntimePrimitive(value)))
    }

    public func increment(_ projection: State<Int>.Projection, by value: Int = 1) {
        registerState(projection)
        actions.append(.increment(key: projection.key.rawValue, by: value))
    }

    public func increment(_ key: StateKey<Int>, by value: Int = 1, initial: Int = 0) {
        states.append(RuntimeStateDefinition(key: key.rawValue, initialValue: .int(initial)))
        actions.append(.increment(key: key.rawValue, by: value))
    }

    public func decrement(_ projection: State<Int>.Projection, by value: Int = 1) {
        registerState(projection)
        actions.append(.decrement(key: projection.key.rawValue, by: value))
    }

    public func decrement(_ key: StateKey<Int>, by value: Int = 1, initial: Int = 0) {
        states.append(RuntimeStateDefinition(key: key.rawValue, initialValue: .int(initial)))
        actions.append(.decrement(key: key.rawValue, by: value))
    }

    public func toggle(_ projection: State<Bool>.Projection) {
        registerState(projection)
        actions.append(.toggle(key: projection.key.rawValue))
    }

    public func toggle(_ key: StateKey<Bool>, initial: Bool = false) {
        states.append(RuntimeStateDefinition(key: key.rawValue, initialValue: .bool(initial)))
        actions.append(.toggle(key: key.rawValue))
    }

    public func navigate(to path: String) {
        actions.append(.navigate(path: path))
    }

    private func registerState<Value: RuntimePrimitiveConvertible>(_ projection: State<Value>.Projection) {
        states.append(
            RuntimeStateDefinition(
                key: projection.key.rawValue,
                initialValue: RuntimePrimitive(projection.initialValue)
            )
        )
    }
}

public extension VariantBuilder {
    func click(_ content: (InteractionScope) -> Void) {
        addInteraction(event: .click, content)
    }

    func input(_ content: (InteractionScope) -> Void) {
        addInteraction(event: .input, content)
    }

    func change(_ content: (InteractionScope) -> Void) {
        addInteraction(event: .change, content)
    }

    func submit(_ content: (InteractionScope) -> Void) {
        addInteraction(event: .submit, content)
    }

    private func addInteraction(event: RuntimeEventType, _ content: (InteractionScope) -> Void) {
        let scope = InteractionScope()
        content(scope)
        guard !scope.actions.isEmpty else {
            return
        }

        if !scope.states.isEmpty {
            registerRuntimeStatePayload(RuntimeDOMCodec.encodeStates(scope.states))
        }

        registerRuntimeActionPayload(
            eventRawValue: event.rawValue,
            payload: RuntimeDOMCodec.encodeActions(scope.actions)
        )
    }
}

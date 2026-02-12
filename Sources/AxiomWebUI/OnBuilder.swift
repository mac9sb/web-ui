import Foundation

public enum RuntimeBindingAttributes {
    public static let states = "data-ax-states"

    public static func event(_ rawValue: String) -> String {
        "data-ax-on-\(rawValue)"
    }
}

public final class VariantBuilder {
    fileprivate var classes: [String] = []
    fileprivate var statePayloads: Set<String> = []
    fileprivate var eventPayloads: [String: [String]] = [:]

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

    public func hover(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: ["hover"], builder: self))
    }

    public func focus(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: ["focus"], builder: self))
    }

    public func active(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: ["active"], builder: self))
    }

    public var classNames: [String] {
        classes
    }

    public var runtimeAttributes: [HTMLAttribute] {
        var attributes: [HTMLAttribute] = []

        if !statePayloads.isEmpty {
            let value = statePayloads.sorted().joined(separator: ",")
            attributes.append(HTMLAttribute(RuntimeBindingAttributes.states, value))
        }

        for event in eventPayloads.keys.sorted() {
            let payloads = eventPayloads[event, default: []]
            guard !payloads.isEmpty else { continue }
            attributes.append(HTMLAttribute(RuntimeBindingAttributes.event(event), payloads.joined(separator: ",")))
        }

        return attributes
    }

    public func registerRuntimeStatePayload(_ payload: String) {
        guard !payload.isEmpty else { return }
        for token in payload.split(separator: ",").map(String.init) where !token.isEmpty {
            statePayloads.insert(token)
        }
    }

    public func registerRuntimeActionPayload(eventRawValue: String, payload: String) {
        guard !payload.isEmpty else { return }
        eventPayloads[eventRawValue, default: []].append(payload)
    }
}

public struct VariantScope {
    fileprivate let prefixes: [String]
    fileprivate let builder: VariantBuilder

    fileprivate init(prefixes: [String], builder: VariantBuilder) {
        self.prefixes = prefixes
        self.builder = builder
    }

    public func addClass(_ rawClass: String) {
        builder.classes.append((prefixes + [rawClass]).joined(separator: ":"))
    }

    public func dark(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: prefixes + ["dark"], builder: builder))
    }

    public func sm(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: prefixes + ["sm"], builder: builder))
    }

    public func md(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: prefixes + ["md"], builder: builder))
    }

    public func lg(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: prefixes + ["lg"], builder: builder))
    }

    public func hover(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: prefixes + ["hover"], builder: builder))
    }

    public func focus(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: prefixes + ["focus"], builder: builder))
    }

    public func active(_ content: (VariantScope) -> Void) {
        content(VariantScope(prefixes: prefixes + ["active"], builder: builder))
    }
}

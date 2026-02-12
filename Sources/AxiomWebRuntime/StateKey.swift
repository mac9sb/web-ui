public struct StateKey<Value: Sendable>: Sendable, Hashable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

@propertyWrapper
public struct State<Value: Sendable>: Sendable {
    public struct Projection: Sendable {
        public let key: StateKey<Value>
        public let initialValue: Value

        public init(key: StateKey<Value>, initialValue: Value) {
            self.key = key
            self.initialValue = initialValue
        }
    }

    private var value: Value
    private let key: StateKey<Value>

    public init(
        wrappedValue: Value,
        _ key: String? = nil,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.value = wrappedValue
        if let key, !key.isEmpty {
            self.key = StateKey<Value>(key)
        } else {
            self.key = StateKey<Value>("state:\(file):\(line)")
        }
    }

    public var wrappedValue: Value {
        get { value }
        set { value = newValue }
    }

    public var projectedValue: Projection {
        Projection(key: key, initialValue: value)
    }
}

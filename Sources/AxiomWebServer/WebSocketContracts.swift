import Foundation
import NIOWebSocket

private func normalizedWebSocketPath(_ path: String) -> String {
    let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
        return "/ws"
    }

    let normalized = trimmed.hasPrefix("/") ? trimmed : "/\(trimmed)"
    if normalized == "/ws" || normalized.hasPrefix("/ws/") {
        return normalized
    }
    if normalized == "/" {
        return "/ws"
    }
    return "/ws\(normalized)"
}

public struct WebSocketConnectionContext: Sendable, Equatable {
    public let path: String
    public let headers: [String: String]

    public init(path: String, headers: [String: String] = [:]) {
        self.path = normalizedWebSocketPath(path)
        self.headers = headers
    }
}

public enum WebSocketMessageKind: String, Sendable, Equatable, Codable {
    case continuation
    case text
    case binary
    case connectionClose
    case ping
    case pong

    public init(opcode: WebSocketOpcode) {
        switch opcode {
        case .continuation:
            self = .continuation
        case .text:
            self = .text
        case .binary:
            self = .binary
        case .connectionClose:
            self = .connectionClose
        case .ping:
            self = .ping
        case .pong:
            self = .pong
        default:
            self = .continuation
        }
    }

    public var nioOpcode: WebSocketOpcode {
        switch self {
        case .continuation:
            return .continuation
        case .text:
            return .text
        case .binary:
            return .binary
        case .connectionClose:
            return .connectionClose
        case .ping:
            return .ping
        case .pong:
            return .pong
        }
    }
}

public struct WebSocketMessage: Sendable, Equatable {
    public let kind: WebSocketMessageKind
    public let data: Data

    public init(kind: WebSocketMessageKind, data: Data = Data()) {
        self.kind = kind
        self.data = data
    }

    public static func text(_ value: String) -> WebSocketMessage {
        WebSocketMessage(kind: .text, data: Data(value.utf8))
    }

    public static func binary(_ value: Data) -> WebSocketMessage {
        WebSocketMessage(kind: .binary, data: value)
    }
}

public protocol WebSocketRouteContract: Sendable {
    static var path: String { get }
    func handle(message: WebSocketMessage, context: WebSocketConnectionContext) async throws -> WebSocketMessage?
}

public struct AnyWebSocketRouteContract: Sendable {
    public let path: String
    private let bridge: @Sendable (WebSocketMessage, WebSocketConnectionContext) async throws -> WebSocketMessage?

    public init<C: WebSocketRouteContract>(_ contract: C) {
        self.path = normalizedWebSocketPath(C.path)
        self.bridge = { message, context in
            try await contract.handle(message: message, context: context)
        }
    }

    public init(
        path: String,
        handle: @escaping @Sendable (WebSocketMessage, WebSocketConnectionContext) async throws -> WebSocketMessage?
    ) {
        self.path = normalizedWebSocketPath(path)
        self.bridge = handle
    }

    public func asRouteHandler() -> WebSocketRouteHandler {
        WebSocketRouteHandler(path: path) { context, message in
            try await bridge(message, context)
        }
    }
}

public struct WebSocketRouteHandler: Sendable {
    public let path: String
    public let handle: @Sendable (WebSocketConnectionContext, WebSocketMessage) async throws -> WebSocketMessage?

    public init(
        path: String,
        handle: @escaping @Sendable (WebSocketConnectionContext, WebSocketMessage) async throws -> WebSocketMessage?
    ) {
        self.path = normalizedWebSocketPath(path)
        self.handle = handle
    }
}

public struct WebSocketRouteOverride: Sendable, Equatable {
    public let path: String

    public init(path: String) {
        self.path = normalizedWebSocketPath(path)
    }
}

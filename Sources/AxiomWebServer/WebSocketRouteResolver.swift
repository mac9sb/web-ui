import Foundation

public enum WebSocketRouteResolutionError: Error, Equatable {
    case routeConflict(path: String)
    case missingHandlerForDiscoveredRoute(path: String)
}

public enum WebSocketRouteResolver {
    public static func resolve(
        routesRoot: URL = URL(filePath: "Routes"),
        websocketDirectory: String = "ws",
        overrides: [WebSocketRouteHandler] = [],
        contracts: [AnyWebSocketRouteContract] = [],
        conflictPolicy: RouteConflictPolicy = .preferOverrides,
        strictContracts: Bool = false
    ) throws -> [WebSocketRouteHandler] {
        let discovered = try RouteDiscovery.discover(
            routesRoot: routesRoot,
            pagesDirectory: "pages",
            apiDirectory: "api",
            websocketDirectory: websocketDirectory
        )
        .filter { $0.kind == .websocket }

        var byPath: [String: WebSocketRouteHandler] = [:]

        for override in overrides {
            try register(handler: normalize(handler: override), into: &byPath, conflictPolicy: conflictPolicy, override: true)
        }

        for contract in contracts {
            try register(handler: normalize(handler: contract.asRouteHandler()), into: &byPath, conflictPolicy: conflictPolicy, override: true)
        }

        for route in discovered {
            let path = normalizePath(route.path)
            if byPath[path] != nil {
                if conflictPolicy == .failBuild {
                    throw WebSocketRouteResolutionError.routeConflict(path: path)
                }
                continue
            }

            if strictContracts {
                throw WebSocketRouteResolutionError.missingHandlerForDiscoveredRoute(path: path)
            }

            let placeholder = WebSocketRouteHandler(path: path) { _, _ in nil }
            try register(handler: placeholder, into: &byPath, conflictPolicy: conflictPolicy, override: false)
        }

        return byPath.values.sorted { $0.path < $1.path }
    }

    private static func register(
        handler: WebSocketRouteHandler,
        into routes: inout [String: WebSocketRouteHandler],
        conflictPolicy: RouteConflictPolicy,
        override: Bool
    ) throws {
        let path = normalizePath(handler.path)
        if routes[path] != nil {
            switch conflictPolicy {
            case .failBuild:
                throw WebSocketRouteResolutionError.routeConflict(path: path)
            case .preferOverrides:
                if !override {
                    return
                }
            }
        }
        routes[path] = handler
    }

    private static func normalize(handler: WebSocketRouteHandler) -> WebSocketRouteHandler {
        WebSocketRouteHandler(path: normalizePath(handler.path), handle: handler.handle)
    }

    private static func normalizePath(_ path: String) -> String {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "/ws" }
        let normalized = trimmed.hasPrefix("/") ? trimmed : "/\(trimmed)"
        if normalized == "/ws" || normalized.hasPrefix("/ws/") {
            return normalized
        }
        if normalized == "/" {
            return "/ws"
        }
        return "/ws\(normalized)"
    }
}


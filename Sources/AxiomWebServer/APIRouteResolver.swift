import Foundation
import HTTPTypes

public enum APIRouteResolutionError: Error, Equatable {
    case routeConflict(path: String, method: String)
}

public enum APIRouteResolver {
    public static func resolve(
        routesRoot: URL = URL(filePath: "Routes"),
        apiDirectory: String = "api",
        overrides: [APIRouteHandler] = [],
        contracts: [AnyAPIRouteContract] = [],
        conflictPolicy: RouteConflictPolicy = .preferOverrides
    ) throws -> [APIRouteHandler] {
        let discovered = try RouteDiscovery.discover(routesRoot: routesRoot, pagesDirectory: "pages", apiDirectory: apiDirectory)
            .filter { $0.kind == .api }

        var byKey: [RouteKey: APIRouteHandler] = [:]

        for route in discovered {
            let normalizedPath = normalizePath(route.path)
            let handler = placeholderHandler(path: normalizedPath)
            try register(handler: handler, into: &byKey, conflictPolicy: conflictPolicy, override: false)
        }

        for override in overrides {
            try register(handler: normalize(handler: override), into: &byKey, conflictPolicy: conflictPolicy, override: true)
        }

        for contract in contracts {
            try register(handler: normalize(handler: contract.asRouteHandler()), into: &byKey, conflictPolicy: conflictPolicy, override: true)
        }

        return byKey
            .values
            .sorted {
                if $0.path == $1.path {
                    return $0.method.rawValue < $1.method.rawValue
                }
                return $0.path < $1.path
            }
    }

    private static func placeholderHandler(path: String) -> APIRouteHandler {
        APIRouteHandler(path: path, method: .get) { _, _ in
            var fields = HTTPFields()
            fields[.contentType] = "application/json; charset=utf-8"
            let body = Data("{\"error\":\"No API handler registered for \\(path)\"}".utf8)
            return (HTTPResponse(status: .notImplemented, headerFields: fields), body)
        }
    }

    private static func register(
        handler: APIRouteHandler,
        into routes: inout [RouteKey: APIRouteHandler],
        conflictPolicy: RouteConflictPolicy,
        override: Bool
    ) throws {
        let key = RouteKey(path: handler.path, method: handler.method.rawValue.uppercased())
        if routes[key] != nil {
            switch conflictPolicy {
            case .failBuild:
                throw APIRouteResolutionError.routeConflict(path: key.path, method: key.method)
            case .preferOverrides:
                if !override {
                    return
                }
            }
        }
        routes[key] = handler
    }

    private static func normalize(handler: APIRouteHandler) -> APIRouteHandler {
        APIRouteHandler(path: normalizePath(handler.path), method: handler.method, handle: handler.handle)
    }

    private static func normalizePath(_ path: String) -> String {
        if path.isEmpty { return "/" }
        if path.hasPrefix("/") { return path }
        return "/\(path)"
    }

    private struct RouteKey: Hashable {
        let path: String
        let method: String
    }
}

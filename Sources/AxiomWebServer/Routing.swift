import Foundation

public enum RouteKind: Sendable, Equatable {
    case page
    case api
}

public struct DiscoveredRoute: Sendable, Equatable {
    public let kind: RouteKind
    public let source: String
    public let path: String

    public init(kind: RouteKind, source: String, path: String) {
        self.kind = kind
        self.source = source
        self.path = path
    }
}

public enum RouteDiscovery {
    public static func discover(
        routesRoot: URL,
        pagesDirectory: String = "pages",
        apiDirectory: String = "api"
    ) throws -> [DiscoveredRoute] {
        var routes: [DiscoveredRoute] = []
        let fileManager = FileManager.default

        let pagesRoot = routesRoot.appending(path: pagesDirectory)
        let apiRoot = routesRoot.appending(path: apiDirectory)

        if fileManager.fileExists(atPath: pagesRoot.path()) {
            routes.append(contentsOf: try discoverRoutes(in: pagesRoot, kind: .page, prefix: ""))
        }

        if fileManager.fileExists(atPath: apiRoot.path()) {
            routes.append(contentsOf: try discoverRoutes(in: apiRoot, kind: .api, prefix: "/api"))
        }

        return routes.sorted {
            if $0.kind == $1.kind {
                return $0.path < $1.path
            }
            return ($0.kind == .page && $1.kind == .api)
        }
    }

    private static func discoverRoutes(
        in root: URL,
        kind: RouteKind,
        prefix: String
    ) throws -> [DiscoveredRoute] {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: root, includingPropertiesForKeys: [.isRegularFileKey]) else {
            return []
        }

        var routes: [DiscoveredRoute] = []
        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension == "swift" else { continue }
            let relativeComponents = fileURL.standardizedFileURL.pathComponents.dropFirst(root.standardizedFileURL.pathComponents.count)
            let relative = relativeComponents.joined(separator: "/")
            let routePath = path(fromRelativeSource: relative, prefix: prefix)
            routes.append(DiscoveredRoute(kind: kind, source: relative, path: routePath))
        }

        return routes
    }

    static func path(fromRelativeSource relative: String, prefix: String) -> String {
        let components = relative.split(separator: "/").map(String.init)
        guard !components.isEmpty else { return prefix.isEmpty ? "/" : prefix }

        var output: [String] = []
        for component in components {
            var name = component
            if name.hasSuffix(".swift") {
                name = String(name.dropLast(6))
            }

            if name == "index" {
                continue
            }

            if name.hasPrefix("[") && name.hasSuffix("]") {
                let dynamic = String(name.dropFirst().dropLast())
                if dynamic.hasPrefix("...") {
                    output.append("*\(dynamic.dropFirst(3))")
                } else {
                    output.append(":\(dynamic)")
                }
            } else {
                output.append(name)
            }
        }

        let joined = output.joined(separator: "/")
        let route = joined.isEmpty ? "/" : "/\(joined)"

        guard !prefix.isEmpty else {
            return route
        }

        if route == "/" {
            return prefix
        }
        return prefix + route
    }
}

import Foundation
import NIOCore
import NIOPosix
import NIOWebSocket
import HTTPTypes
import Tracing
import Logging
import Metrics
import ServiceLifecycle

public struct APIRouteHandler: Sendable {
    public let path: String
    public let method: HTTPRequest.Method
    public let handle: @Sendable (HTTPRequest, Data?) async throws -> (HTTPResponse, Data)

    public init(
        path: String,
        method: HTTPRequest.Method = .get,
        handle: @escaping @Sendable (HTTPRequest, Data?) async throws -> (HTTPResponse, Data)
    ) {
        self.path = path
        self.method = method
        self.handle = handle
    }
}

public struct ServerRuntimeConfiguration: Sendable {
    public var host: String
    public var port: Int
    public var observability: ObservabilityConfiguration

    public init(host: String = "127.0.0.1", port: Int = 8080, observability: ObservabilityConfiguration = .init()) {
        self.host = host
        self.port = port
        self.observability = observability
    }
}

public final class AxiomWebServerRuntime {
    public let configuration: ServerRuntimeConfiguration
    public let routes: [APIRouteHandler]
    public let websocketRoutes: [WebSocketRouteHandler]

    public init(
        configuration: ServerRuntimeConfiguration = .init(),
        routes: [APIRouteHandler] = [],
        websocketRoutes: [WebSocketRouteHandler] = []
    ) {
        self.configuration = configuration
        self.routes = routes
        self.websocketRoutes = websocketRoutes
    }

    public convenience init(
        configuration: ServerRuntimeConfiguration = .init(),
        routesRoot: URL = URL(filePath: "Routes"),
        apiDirectory: String = "api",
        websocketDirectory: String = "ws",
        overrides: RouteOverrides = .init(),
        conflictPolicy: RouteConflictPolicy = .preferOverrides,
        strictContracts: Bool = false
    ) throws {
        let resolvedRoutes = try APIRouteResolver.resolve(
            routesRoot: routesRoot,
            apiDirectory: apiDirectory,
            overrides: overrides.apiHandlers,
            contracts: overrides.apiContracts,
            conflictPolicy: conflictPolicy,
            strictContracts: strictContracts
        )
        let resolvedWebSocketRoutes = try WebSocketRouteResolver.resolve(
            routesRoot: routesRoot,
            websocketDirectory: websocketDirectory,
            overrides: overrides.websocketHandlers,
            contracts: overrides.websocketContracts,
            conflictPolicy: conflictPolicy,
            strictContracts: strictContracts
        )
        self.init(configuration: configuration, routes: resolvedRoutes, websocketRoutes: resolvedWebSocketRoutes)
    }

    // Placeholder runtime scaffold showing dependency integration.
    public func start() async throws {
        let logger = Logger(label: "AxiomWeb.ServerRuntime")
        let startupCounter = Counter(label: "axiomweb.runtime.start")
        if configuration.observability.enabled {
            logger.info("Starting runtime on \(configuration.host):\(configuration.port) with \(routes.count) API routes and \(websocketRoutes.count) websocket routes")
            startupCounter.increment()
        }

        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let lifecycleGroup = ServiceGroup(
            services: [ServerRuntimeLifecycleService(eventLoopGroup: eventLoopGroup)],
            gracefulShutdownSignals: [.sigterm, .sigint],
            logger: logger
        )

        do {
            try await lifecycleGroup.run()
        } catch {
            try? await eventLoopGroup.shutdownGracefully()
            throw error
        }

        try await eventLoopGroup.shutdownGracefully()
    }
}

private struct ServerRuntimeLifecycleService: Service {
    let eventLoopGroup: MultiThreadedEventLoopGroup

    func run() async throws {
        _ = eventLoopGroup
        while !Task.isCancelled {
            try await Task.sleep(nanoseconds: 500_000_000)
        }
    }

    func shutdown() async {
        // Event loop group shutdown is performed by runtime defer for now.
    }
}

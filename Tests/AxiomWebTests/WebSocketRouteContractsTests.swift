import Foundation
import Testing
@testable import AxiomWebServer

@Suite("WebSocket Route Contracts")
struct WebSocketRouteContractsTests {
    @Test("Converts typed websocket contract into runtime handler")
    func convertsTypedWebSocketContractToHandler() async throws {
        struct EchoContract: WebSocketRouteContract {
            static var path: String { "/ws/echo" }

            func handle(message: WebSocketMessage, context: WebSocketConnectionContext) async throws -> WebSocketMessage? {
                message
            }
        }

        let handler = AnyWebSocketRouteContract(EchoContract()).asRouteHandler()
        let context = WebSocketConnectionContext(path: "/ws/echo")
        let inbound = WebSocketMessage.text("hello")
        let outbound = try await handler.handle(context, inbound)
        #expect(outbound == inbound)
    }

    @Test("Resolves websocket routes with contract overrides")
    func resolvesWebSocketRoutesWithContractOverrides() throws {
        let root = FileManager.default.temporaryDirectory.appending(path: "axiomweb-ws-routes-\(UUID().uuidString)")
        let ws = root.appending(path: "ws")
        try FileManager.default.createDirectory(at: ws, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: ws.appending(path: "echo.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: root) }

        struct EchoContract: WebSocketRouteContract {
            static var path: String { "/ws/echo" }

            func handle(message: WebSocketMessage, context: WebSocketConnectionContext) async throws -> WebSocketMessage? {
                .text("ok")
            }
        }

        let resolved = try WebSocketRouteResolver.resolve(
            routesRoot: root,
            websocketDirectory: "ws",
            contracts: [AnyWebSocketRouteContract(EchoContract())],
            conflictPolicy: .preferOverrides
        )

        #expect(resolved.count == 1)
        #expect(resolved.first?.path == "/ws/echo")
    }

    @Test("Strict websocket contract mode fails when discovered websocket route is unregistered")
    func strictWebSocketContractModeFailsWhenDiscoveredRouteIsUnregistered() throws {
        let root = FileManager.default.temporaryDirectory.appending(path: "axiomweb-ws-strict-\(UUID().uuidString)")
        let ws = root.appending(path: "ws")
        try FileManager.default.createDirectory(at: ws, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: ws.appending(path: "events.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: root) }

        #expect(throws: WebSocketRouteResolutionError.self) {
            _ = try WebSocketRouteResolver.resolve(
                routesRoot: root,
                websocketDirectory: "ws",
                strictContracts: true
            )
        }
    }

    @Test("RouteOverrides can infer websocket path from source and register handlers")
    func routeOverridesCanInferWebSocketPathFromSourceAndRegisterHandlers() async throws {
        var overrides = RouteOverrides()
        overrides.websocket(from: "chat/echo.swift") { message, _ in
            message
        }

        #expect(overrides.websocketOverrides.count == 1)
        #expect(overrides.websocketOverrides.first?.path == "/ws/chat/echo")
        #expect(overrides.websocketHandlers.count == 1)

        let context = WebSocketConnectionContext(path: "/ws/chat/echo")
        let inbound = WebSocketMessage.text("ping")
        let outbound = try await overrides.websocketHandlers[0].handle(context, inbound)
        #expect(outbound == inbound)
    }
}


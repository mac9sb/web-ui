import Foundation
import Testing
@testable import AxiomWebServer

@Suite("Routing")
struct RoutingTests {
    @Test("Discovers page, API, and websocket routes from conventions")
    func discoversRoutes() throws {
        let root = FileManager.default.temporaryDirectory.appending(path: "axiomweb-routes-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let pages = root.appending(path: "pages")
        let api = root.appending(path: "api")
        let ws = root.appending(path: "ws")
        try FileManager.default.createDirectory(at: pages.appending(path: "path"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: api.appending(path: "path"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: ws.appending(path: "chat"), withIntermediateDirectories: true)

        FileManager.default.createFile(atPath: pages.appending(path: "index.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: pages.appending(path: "contact.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: pages.appending(path: "path/goodbye.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: api.appending(path: "hello.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: api.appending(path: "path/goodbye.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: ws.appending(path: "chat/echo.swift").path(), contents: Data())

        let routes = try RouteDiscovery.discover(routesRoot: root)
        let paths = Set(routes.map(\.path))

        #expect(paths.contains("/"))
        #expect(paths.contains("/contact"))
        #expect(paths.contains("/path/goodbye"))
        #expect(paths.contains("/api/hello"))
        #expect(paths.contains("/api/path/goodbye"))
        #expect(paths.contains("/ws/chat/echo"))
    }

    @Test("Infers page, API, and websocket paths from source-relative route files")
    func infersPathFromSourceFile() {
        #expect(RoutePathInference.pagePath(fromSource: "index.swift") == "/")
        #expect(RoutePathInference.pagePath(fromSource: "contact.swift") == "/contact")
        #expect(RoutePathInference.pagePath(fromSource: "path/goodbye.swift") == "/path/goodbye")
        #expect(RoutePathInference.pagePath(fromSource: "[slug].swift") == "/:slug")
        #expect(RoutePathInference.pagePath(fromSource: "[...path].swift") == "/*path")

        #expect(RoutePathInference.apiPath(fromSource: "hello.swift") == "/api/hello")
        #expect(RoutePathInference.apiPath(fromSource: "path/goodbye.swift") == "/api/path/goodbye")
        #expect(RoutePathInference.apiPath(fromSource: "[id].swift") == "/api/:id")

        #expect(RoutePathInference.websocketPath(fromSource: "echo.swift") == "/ws/echo")
        #expect(RoutePathInference.websocketPath(fromSource: "chat/[room].swift") == "/ws/chat/:room")
    }
}

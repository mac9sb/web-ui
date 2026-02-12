import Foundation
import Testing
@testable import AxiomWebServer

@Suite("Routing")
struct RoutingTests {
    @Test("Discovers page and API routes from conventions")
    func discoversRoutes() throws {
        let root = FileManager.default.temporaryDirectory.appending(path: "axiomweb-routes-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let pages = root.appending(path: "pages")
        let api = root.appending(path: "api")
        try FileManager.default.createDirectory(at: pages.appending(path: "path"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: api.appending(path: "path"), withIntermediateDirectories: true)

        FileManager.default.createFile(atPath: pages.appending(path: "index.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: pages.appending(path: "contact.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: pages.appending(path: "path/goodbye.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: api.appending(path: "hello.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: api.appending(path: "path/goodbye.swift").path(), contents: Data())

        let routes = try RouteDiscovery.discover(routesRoot: root)
        let paths = Set(routes.map(\.path))

        #expect(paths.contains("/"))
        #expect(paths.contains("/contact"))
        #expect(paths.contains("/path/goodbye"))
        #expect(paths.contains("/api/hello"))
        #expect(paths.contains("/api/path/goodbye"))
    }
}

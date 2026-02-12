import Foundation
import Testing
import HTTPTypes
@testable import AxiomWebServer

@Suite("API Route Contracts")
struct APIRouteContractsTests {
    @Test("Converts typed API contract into runtime handler")
    func convertsTypedContractToHandler() async throws {
        struct HelloResponse: Codable, Equatable, Sendable {
            let message: String
        }

        struct HelloContract: APIRouteContract {
            static var method: HTTPRequest.Method { .get }
            static var path: String { "/api/hello" }

            func handle(request: EmptyAPIRequest, context: APIRequestContext) async throws -> APIResponse<HelloResponse> {
                APIResponse(body: HelloResponse(message: "hello"))
            }
        }

        let handler = AnyAPIRouteContract(HelloContract()).asRouteHandler()
        let request = HTTPRequest(method: .get, scheme: nil, authority: nil, path: "/api/hello")
        let (response, body) = try await handler.handle(request, nil)

        #expect(response.status.code == 200)
        let decoded = try JSONDecoder().decode(HelloResponse.self, from: body)
        #expect(decoded == HelloResponse(message: "hello"))
    }

    @Test("Resolves /Routes/api with contract override preference")
    func resolvesRoutesWithContractOverrides() async throws {
        struct GoodbyeResponse: Codable, Equatable, Sendable {
            let ok: Bool
        }

        struct GoodbyeContract: APIRouteContract {
            static var method: HTTPRequest.Method { .get }
            static var path: String { "/api/hello" }

            func handle(request: EmptyAPIRequest, context: APIRequestContext) async throws -> APIResponse<GoodbyeResponse> {
                APIResponse(body: GoodbyeResponse(ok: true))
            }
        }

        let root = FileManager.default.temporaryDirectory.appending(path: "axiomweb-api-routes-\(UUID().uuidString)")
        let api = root.appending(path: "api")
        try FileManager.default.createDirectory(at: api, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: api.appending(path: "hello.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: api.appending(path: "status.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: root) }

        let resolved = try APIRouteResolver.resolve(
            routesRoot: root,
            apiDirectory: "api",
            contracts: [AnyAPIRouteContract(GoodbyeContract())],
            conflictPolicy: .preferOverrides
        )

        #expect(resolved.contains { $0.path == "/api/hello" && $0.method == .get })
        #expect(resolved.contains { $0.path == "/api/status" && $0.method == .get })

        guard let hello = resolved.first(where: { $0.path == "/api/hello" && $0.method == .get }) else {
            #expect(Bool(false), "Missing /api/hello route")
            return
        }

        let request = HTTPRequest(method: .get, scheme: nil, authority: nil, path: "/api/hello")
        let (response, body) = try await hello.handle(request, nil)
        #expect(response.status.code == 200)
        let decoded = try JSONDecoder().decode(GoodbyeResponse.self, from: body)
        #expect(decoded == GoodbyeResponse(ok: true))
    }

    @Test("Fails resolution on conflict in strict mode")
    func failsOnConflictInStrictMode() throws {
        struct DuplicateContract: APIRouteContract {
            static var method: HTTPRequest.Method { .get }
            static var path: String { "/api/hello" }

            func handle(request: EmptyAPIRequest, context: APIRequestContext) async throws -> APIResponse<Bool> {
                APIResponse(body: true)
            }
        }

        let root = FileManager.default.temporaryDirectory.appending(path: "axiomweb-api-conflict-\(UUID().uuidString)")
        let api = root.appending(path: "api")
        try FileManager.default.createDirectory(at: api, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: api.appending(path: "hello.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: root) }

        #expect(throws: APIRouteResolutionError.self) {
            _ = try APIRouteResolver.resolve(
                routesRoot: root,
                apiDirectory: "api",
                contracts: [AnyAPIRouteContract(DuplicateContract())],
                conflictPolicy: .failBuild
            )
        }
    }
}

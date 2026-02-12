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

    @Test("Supports multiple methods for the same API path via contracts")
    func supportsMultipleMethodsForSamePathViaContracts() async throws {
        struct MultiGetContract: APIRouteContract {
            static var method: HTTPRequest.Method { .get }
            static var path: String { "/api/hello" }

            func handle(request: EmptyAPIRequest, context: APIRequestContext) async throws -> APIResponse<String> {
                APIResponse(body: "get")
            }
        }

        struct MultiPostContract: APIRouteContract {
            static var method: HTTPRequest.Method { .post }
            static var path: String { "/api/hello" }

            func handle(request: EmptyAPIRequest, context: APIRequestContext) async throws -> APIResponse<String> {
                APIResponse(body: "post")
            }
        }

        let root = FileManager.default.temporaryDirectory.appending(path: "axiomweb-api-method-contracts-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let resolved = try APIRouteResolver.resolve(
            routesRoot: root,
            apiDirectory: "api",
            contracts: [AnyAPIRouteContract(MultiGetContract()), AnyAPIRouteContract(MultiPostContract())],
            conflictPolicy: .failBuild
        )

        #expect(resolved.contains { $0.path == "/api/hello" && $0.method == .get })
        #expect(resolved.contains { $0.path == "/api/hello" && $0.method == .post })

        guard let getHandler = resolved.first(where: { $0.path == "/api/hello" && $0.method == .get }) else {
            #expect(Bool(false), "Missing GET /api/hello route")
            return
        }
        guard let postHandler = resolved.first(where: { $0.path == "/api/hello" && $0.method == .post }) else {
            #expect(Bool(false), "Missing POST /api/hello route")
            return
        }

        let getRequest = HTTPRequest(method: .get, scheme: nil, authority: nil, path: "/api/hello")
        let postRequest = HTTPRequest(method: .post, scheme: nil, authority: nil, path: "/api/hello")

        let (_, getBody) = try await getHandler.handle(getRequest, nil)
        let (_, postBody) = try await postHandler.handle(postRequest, nil)

        #expect(String(decoding: getBody, as: UTF8.self).contains("\"get\""))
        #expect(String(decoding: postBody, as: UTF8.self).contains("\"post\""))
    }

    @Test("RouteOverrides can register multiple methods for one path")
    func routeOverridesCanRegisterMultipleMethods() throws {
        var overrides = RouteOverrides()
        overrides.api("/api/hello", methods: [.post, .get, .get]) { request, _ in
            var fields = HTTPFields()
            fields[.contentType] = "application/json; charset=utf-8"
            let body = Data("{\"method\":\"\(request.method.rawValue)\"}".utf8)
            return (HTTPResponse(status: .ok, headerFields: fields), body)
        }

        let methods = Set(overrides.apiOverrides.map(\.method))
        #expect(methods == ["GET", "POST"])
        #expect(overrides.apiHandlers.count == 2)
    }

    @Test("RouteOverrides can infer API path from source and register typed handlers")
    func routeOverridesCanInferPathFromSourceAndRegisterTypedHandlers() async throws {
        struct CreateRequest: Codable, Sendable {
            let name: String
        }

        struct MessageResponse: Codable, Equatable, Sendable {
            let message: String
        }

        struct PatchRequest: Codable, Sendable {
            let enabled: Bool
        }

        var overrides = RouteOverrides()
        overrides.api(from: "hello.swift") { route in
            route.get { _ in
                APIResponse(body: MessageResponse(message: "hello:get"))
            }

            route.post { (request: CreateRequest, _) in
                APIResponse(statusCode: 201, body: MessageResponse(message: "hello:\(request.name)"))
            }

            route.patch { (request: PatchRequest, _) in
                APIResponse(body: MessageResponse(message: request.enabled ? "hello:on" : "hello:off"))
            }
        }

        #expect(overrides.apiHandlers.count == 3)
        #expect(overrides.apiOverrides.allSatisfy { $0.path == "/api/hello" })
        #expect(Set(overrides.apiOverrides.map(\.method)) == ["GET", "PATCH", "POST"])

        guard let getHandler = overrides.apiHandlers.first(where: { $0.path == "/api/hello" && $0.method == .get }) else {
            #expect(Bool(false), "Expected GET handler at inferred path")
            return
        }

        guard let postHandler = overrides.apiHandlers.first(where: { $0.path == "/api/hello" && $0.method == .post }) else {
            #expect(Bool(false), "Expected POST handler at inferred path")
            return
        }

        guard let patchHandler = overrides.apiHandlers.first(where: { $0.path == "/api/hello" && $0.method == .patch }) else {
            #expect(Bool(false), "Expected PATCH handler at inferred path")
            return
        }

        let getRequest = HTTPRequest(method: .get, scheme: nil, authority: nil, path: "/api/hello")
        let (getResponse, getBody) = try await getHandler.handle(getRequest, nil)
        #expect(getResponse.status.code == 200)
        #expect(try JSONDecoder().decode(MessageResponse.self, from: getBody) == MessageResponse(message: "hello:get"))

        let postBody = try JSONEncoder().encode(CreateRequest(name: "axiom"))
        let postRequest = HTTPRequest(method: .post, scheme: nil, authority: nil, path: "/api/hello")
        let (postResponse, postPayload) = try await postHandler.handle(postRequest, postBody)
        #expect(postResponse.status.code == 201)
        #expect(try JSONDecoder().decode(MessageResponse.self, from: postPayload) == MessageResponse(message: "hello:axiom"))

        let patchBody = try JSONEncoder().encode(PatchRequest(enabled: true))
        let patchRequest = HTTPRequest(method: .patch, scheme: nil, authority: nil, path: "/api/hello")
        let (_, patchPayload) = try await patchHandler.handle(patchRequest, patchBody)
        #expect(try JSONDecoder().decode(MessageResponse.self, from: patchPayload) == MessageResponse(message: "hello:on"))
    }
}

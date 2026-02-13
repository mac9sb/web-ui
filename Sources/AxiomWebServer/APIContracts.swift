import Foundation
import HTTPTypes
import AxiomWebUI

private func normalizedRoutePath(_ path: String) -> String {
    let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
        return "/"
    }
    if trimmed.hasPrefix("/") {
        return trimmed
    }
    return "/\(trimmed)"
}

private func resolvedPageOverridePath(for document: any Document, source: String) -> String {
    let explicitPath = document.path.trimmingCharacters(in: .whitespacesAndNewlines)
    if explicitPath.isEmpty || explicitPath == "index" || explicitPath == "/index" {
        return normalizedRoutePath(RoutePathInference.pagePath(fromSource: source))
    }
    return normalizedRoutePath(explicitPath)
}

public struct EmptyAPIRequest: Codable, Sendable {
    public init() {}
}

public struct APIRequestContext: Sendable {
    public let request: HTTPRequest
    public let rawBody: Data?

    public init(request: HTTPRequest, rawBody: Data?) {
        self.request = request
        self.rawBody = rawBody
    }
}

public struct APIResponse<Body: Encodable & Sendable>: Sendable {
    public let statusCode: Int
    public let headers: [String: String]
    public let body: Body

    public init(statusCode: Int = 200, headers: [String: String] = [:], body: Body) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }
}

public protocol APIRouteContract: Sendable {
    associatedtype RequestBody: Decodable & Sendable
    associatedtype ResponseBody: Encodable & Sendable

    static var method: HTTPRequest.Method { get }
    static var path: String { get }

    func handle(request: RequestBody, context: APIRequestContext) async throws -> APIResponse<ResponseBody>
}

public enum APIRouteContractError: Error, Equatable {
    case missingRequestBody(path: String)
    case requestDecodingFailed(path: String, message: String)
    case responseEncodingFailed(path: String, message: String)
}

public struct AnyAPIRouteContract: Sendable {
    public let path: String
    public let method: HTTPRequest.Method

    private let bridge: @Sendable (HTTPRequest, Data?) async throws -> (HTTPResponse, Data)

    public init<C: APIRouteContract>(_ contract: C) {
        self.init(path: C.path, method: C.method) { (decodedRequest: C.RequestBody, context: APIRequestContext) in
            try await contract.handle(request: decodedRequest, context: context)
        }
    }

    public init<RequestBody: Decodable & Sendable, ResponseBody: Encodable & Sendable>(
        path: String,
        method: HTTPRequest.Method,
        handle: @escaping @Sendable (RequestBody, APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) {
        let normalizedPath = normalizedRoutePath(path)
        self.path = normalizedPath
        self.method = method
        self.bridge = { request, body in
            let decodedRequest: RequestBody = try Self.decodeRequestBody(body, path: normalizedPath)
            let context = APIRequestContext(request: request, rawBody: body)
            let apiResponse = try await handle(decodedRequest, context)
            return try Self.encodeResponse(apiResponse, path: normalizedPath)
        }
    }

    public init<ResponseBody: Encodable & Sendable>(
        path: String,
        method: HTTPRequest.Method,
        handle: @escaping @Sendable (APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) {
        self.init(path: path, method: method) { (_: EmptyAPIRequest, context: APIRequestContext) in
            try await handle(context)
        }
    }

    public func asRouteHandler() -> APIRouteHandler {
        APIRouteHandler(path: path, method: method, handle: bridge)
    }

    private static func decodeRequestBody<RequestBody: Decodable & Sendable>(
        _ body: Data?,
        path: String
    ) throws -> RequestBody {
        if RequestBody.self == EmptyAPIRequest.self {
            return EmptyAPIRequest() as! RequestBody
        }

        guard let body else {
            throw APIRouteContractError.missingRequestBody(path: path)
        }

        do {
            return try JSONDecoder().decode(RequestBody.self, from: body)
        } catch {
            throw APIRouteContractError.requestDecodingFailed(path: path, message: String(describing: error))
        }
    }

    private static func encodeResponse<ResponseBody: Encodable & Sendable>(
        _ response: APIResponse<ResponseBody>,
        path: String
    ) throws -> (HTTPResponse, Data) {
        let payload: Data
        do {
            payload = try JSONEncoder().encode(response.body)
        } catch {
            throw APIRouteContractError.responseEncodingFailed(path: path, message: String(describing: error))
        }

        var fields = HTTPFields()
        for (name, value) in response.headers {
            if let fieldName = HTTPField.Name(name) {
                fields[fieldName] = value
            }
        }
        if fields[.contentType] == nil {
            fields[.contentType] = "application/json; charset=utf-8"
        }

        let statusCode = max(100, min(599, response.statusCode))
        return (HTTPResponse(status: .init(code: statusCode), headerFields: fields), payload)
    }
}

public final class APIMethodRouteBuilder {
    public let path: String
    private(set) var contracts: [AnyAPIRouteContract] = []

    public init(path: String) {
        self.path = normalizedRoutePath(path)
    }

    @discardableResult
    public func on<RequestBody: Decodable & Sendable, ResponseBody: Encodable & Sendable>(
        _ method: HTTPRequest.Method,
        handle: @escaping @Sendable (RequestBody, APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) -> Self {
        contracts.append(AnyAPIRouteContract(path: path, method: method, handle: handle))
        return self
    }

    @discardableResult
    public func on<ResponseBody: Encodable & Sendable>(
        _ method: HTTPRequest.Method,
        handle: @escaping @Sendable (APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) -> Self {
        contracts.append(AnyAPIRouteContract(path: path, method: method, handle: handle))
        return self
    }

    @discardableResult
    public func get<RequestBody: Decodable & Sendable, ResponseBody: Encodable & Sendable>(
        handle: @escaping @Sendable (RequestBody, APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) -> Self {
        on(.get, handle: handle)
    }

    @discardableResult
    public func get<ResponseBody: Encodable & Sendable>(
        handle: @escaping @Sendable (APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) -> Self {
        on(.get, handle: handle)
    }

    @discardableResult
    public func post<RequestBody: Decodable & Sendable, ResponseBody: Encodable & Sendable>(
        handle: @escaping @Sendable (RequestBody, APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) -> Self {
        on(.post, handle: handle)
    }

    @discardableResult
    public func post<ResponseBody: Encodable & Sendable>(
        handle: @escaping @Sendable (APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) -> Self {
        on(.post, handle: handle)
    }

    @discardableResult
    public func put<RequestBody: Decodable & Sendable, ResponseBody: Encodable & Sendable>(
        handle: @escaping @Sendable (RequestBody, APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) -> Self {
        on(.put, handle: handle)
    }

    @discardableResult
    public func put<ResponseBody: Encodable & Sendable>(
        handle: @escaping @Sendable (APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) -> Self {
        on(.put, handle: handle)
    }

    @discardableResult
    public func patch<RequestBody: Decodable & Sendable, ResponseBody: Encodable & Sendable>(
        handle: @escaping @Sendable (RequestBody, APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) -> Self {
        on(.patch, handle: handle)
    }

    @discardableResult
    public func patch<ResponseBody: Encodable & Sendable>(
        handle: @escaping @Sendable (APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) -> Self {
        on(.patch, handle: handle)
    }
}

public struct RouteOverrides {
    public private(set) var pageOverrides: [PageRouteOverride]
    public private(set) var apiOverrides: [APIRouteOverride]
    public private(set) var apiContracts: [AnyAPIRouteContract]
    public private(set) var apiHandlers: [APIRouteHandler]
    public private(set) var websocketOverrides: [WebSocketRouteOverride]
    public private(set) var websocketContracts: [AnyWebSocketRouteContract]
    public private(set) var websocketHandlers: [WebSocketRouteHandler]

    public init(
        pageOverrides: [PageRouteOverride] = [],
        apiOverrides: [APIRouteOverride] = [],
        apiContracts: [AnyAPIRouteContract] = [],
        apiHandlers: [APIRouteHandler] = [],
        websocketOverrides: [WebSocketRouteOverride] = [],
        websocketContracts: [AnyWebSocketRouteContract] = [],
        websocketHandlers: [WebSocketRouteHandler] = []
    ) {
        self.pageOverrides = pageOverrides
        self.apiOverrides = apiOverrides
        self.apiContracts = apiContracts
        self.apiHandlers = apiHandlers
        self.websocketOverrides = websocketOverrides
        self.websocketContracts = websocketContracts
        self.websocketHandlers = websocketHandlers
    }

    public mutating func page(_ path: String, document: any Document) {
        pageOverrides.append(PageRouteOverride(path: normalizedRoutePath(path), document: document))
    }

    public mutating func page(from source: String, document: any Document) {
        let resolvedPath = resolvedPageOverridePath(for: document, source: source)
        pageOverrides.append(PageRouteOverride(path: resolvedPath, document: document))
    }

    public mutating func api(_ path: String, method: HTTPRequest.Method = .get) {
        apiOverrides.append(APIRouteOverride(path: normalizedRoutePath(path), method: method.rawValue))
    }

    public mutating func api(from source: String, method: HTTPRequest.Method = .get) {
        api(RoutePathInference.apiPath(fromSource: source), method: method)
    }

    public mutating func api<C: APIRouteContract>(_ contract: C) {
        let erased = AnyAPIRouteContract(contract)
        register(contract: erased)
    }

    public mutating func api<RequestBody: Decodable & Sendable, ResponseBody: Encodable & Sendable>(
        _ path: String,
        method: HTTPRequest.Method = .get,
        handle: @escaping @Sendable (RequestBody, APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) {
        register(contract: AnyAPIRouteContract(path: path, method: method, handle: handle))
    }

    public mutating func api<RequestBody: Decodable & Sendable, ResponseBody: Encodable & Sendable>(
        from source: String,
        method: HTTPRequest.Method = .get,
        handle: @escaping @Sendable (RequestBody, APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) {
        api(RoutePathInference.apiPath(fromSource: source), method: method, handle: handle)
    }

    public mutating func api<ResponseBody: Encodable & Sendable>(
        _ path: String,
        method: HTTPRequest.Method = .get,
        handle: @escaping @Sendable (APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) {
        register(contract: AnyAPIRouteContract(path: path, method: method, handle: handle))
    }

    public mutating func api<ResponseBody: Encodable & Sendable>(
        from source: String,
        method: HTTPRequest.Method = .get,
        handle: @escaping @Sendable (APIRequestContext) async throws -> APIResponse<ResponseBody>
    ) {
        api(RoutePathInference.apiPath(fromSource: source), method: method, handle: handle)
    }

    public mutating func api(_ path: String, build: (APIMethodRouteBuilder) -> Void) {
        let builder = APIMethodRouteBuilder(path: path)
        build(builder)
        for contract in builder.contracts {
            register(contract: contract)
        }
    }

    public mutating func api(from source: String, build: (APIMethodRouteBuilder) -> Void) {
        api(RoutePathInference.apiPath(fromSource: source), build: build)
    }

    public mutating func api(
        _ path: String,
        method: HTTPRequest.Method = .get,
        handle: @escaping @Sendable (HTTPRequest, Data?) async throws -> (HTTPResponse, Data)
    ) {
        let normalizedPath = normalizedRoutePath(path)
        apiOverrides.append(APIRouteOverride(path: normalizedPath, method: method.rawValue))
        apiHandlers.append(APIRouteHandler(path: normalizedPath, method: method, handle: handle))
    }

    public mutating func api(
        from source: String,
        method: HTTPRequest.Method = .get,
        handle: @escaping @Sendable (HTTPRequest, Data?) async throws -> (HTTPResponse, Data)
    ) {
        api(RoutePathInference.apiPath(fromSource: source), method: method, handle: handle)
    }

    public mutating func api(
        _ path: String,
        methods: [HTTPRequest.Method],
        handle: @escaping @Sendable (HTTPRequest, Data?) async throws -> (HTTPResponse, Data)
    ) {
        let orderedMethods = Set(methods).sorted { $0.rawValue < $1.rawValue }
        for method in orderedMethods {
            api(path, method: method, handle: handle)
        }
    }

    public mutating func api(
        from source: String,
        methods: [HTTPRequest.Method],
        handle: @escaping @Sendable (HTTPRequest, Data?) async throws -> (HTTPResponse, Data)
    ) {
        api(RoutePathInference.apiPath(fromSource: source), methods: methods, handle: handle)
    }

    public mutating func websocket(_ path: String) {
        websocketOverrides.append(WebSocketRouteOverride(path: path))
    }

    public mutating func websocket(from source: String) {
        websocket(RoutePathInference.websocketPath(fromSource: source))
    }

    public mutating func websocket<C: WebSocketRouteContract>(_ contract: C) {
        register(websocketContract: AnyWebSocketRouteContract(contract))
    }

    public mutating func websocket(
        _ path: String,
        handle: @escaping @Sendable (WebSocketMessage, WebSocketConnectionContext) async throws -> WebSocketMessage?
    ) {
        register(websocketContract: AnyWebSocketRouteContract(path: path, handle: handle))
    }

    public mutating func websocket(
        from source: String,
        handle: @escaping @Sendable (WebSocketMessage, WebSocketConnectionContext) async throws -> WebSocketMessage?
    ) {
        websocket(RoutePathInference.websocketPath(fromSource: source), handle: handle)
    }

    private mutating func register(contract: AnyAPIRouteContract) {
        apiContracts.append(contract)
        apiOverrides.append(APIRouteOverride(path: contract.path, method: contract.method.rawValue))
        apiHandlers.append(contract.asRouteHandler())
    }

    private mutating func register(websocketContract: AnyWebSocketRouteContract) {
        websocketContracts.append(websocketContract)
        websocketOverrides.append(WebSocketRouteOverride(path: websocketContract.path))
        websocketHandlers.append(websocketContract.asRouteHandler())
    }
}

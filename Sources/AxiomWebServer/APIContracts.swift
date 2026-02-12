import Foundation
import HTTPTypes
import AxiomWebUI

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
        self.path = C.path
        self.method = C.method
        self.bridge = { request, body in
            let decodedRequest: C.RequestBody
            if C.RequestBody.self == EmptyAPIRequest.self {
                decodedRequest = EmptyAPIRequest() as! C.RequestBody
            } else {
                guard let body else {
                    throw APIRouteContractError.missingRequestBody(path: C.path)
                }
                do {
                    decodedRequest = try JSONDecoder().decode(C.RequestBody.self, from: body)
                } catch {
                    throw APIRouteContractError.requestDecodingFailed(path: C.path, message: String(describing: error))
                }
            }

            let context = APIRequestContext(request: request, rawBody: body)
            let apiResponse = try await contract.handle(request: decodedRequest, context: context)

            let payload: Data
            do {
                payload = try JSONEncoder().encode(apiResponse.body)
            } catch {
                throw APIRouteContractError.responseEncodingFailed(path: C.path, message: String(describing: error))
            }

            var fields = HTTPFields()
            for (name, value) in apiResponse.headers {
                if let fieldName = HTTPField.Name(name) {
                    fields[fieldName] = value
                }
            }
            if fields[.contentType] == nil {
                fields[.contentType] = "application/json; charset=utf-8"
            }

            let statusCode = max(100, min(599, apiResponse.statusCode))
            let response = HTTPResponse(status: .init(code: statusCode), headerFields: fields)
            return (response, payload)
        }
    }

    public func asRouteHandler() -> APIRouteHandler {
        APIRouteHandler(path: path, method: method, handle: bridge)
    }
}

public struct RouteOverrides {
    public private(set) var pageOverrides: [PageRouteOverride]
    public private(set) var apiOverrides: [APIRouteOverride]
    public private(set) var apiContracts: [AnyAPIRouteContract]
    public private(set) var apiHandlers: [APIRouteHandler]

    public init(
        pageOverrides: [PageRouteOverride] = [],
        apiOverrides: [APIRouteOverride] = [],
        apiContracts: [AnyAPIRouteContract] = [],
        apiHandlers: [APIRouteHandler] = []
    ) {
        self.pageOverrides = pageOverrides
        self.apiOverrides = apiOverrides
        self.apiContracts = apiContracts
        self.apiHandlers = apiHandlers
    }

    public mutating func page(_ path: String, document: any Document) {
        pageOverrides.append(PageRouteOverride(path: path, document: document))
    }

    public mutating func api(_ path: String, method: HTTPRequest.Method = .get) {
        apiOverrides.append(APIRouteOverride(path: path, method: method.rawValue))
    }

    public mutating func api<C: APIRouteContract>(_ contract: C) {
        let erased = AnyAPIRouteContract(contract)
        apiContracts.append(erased)
        apiOverrides.append(APIRouteOverride(path: erased.path, method: erased.method.rawValue))
        apiHandlers.append(erased.asRouteHandler())
    }

    public mutating func api(
        _ path: String,
        method: HTTPRequest.Method = .get,
        handle: @escaping @Sendable (HTTPRequest, Data?) async throws -> (HTTPResponse, Data)
    ) {
        apiOverrides.append(APIRouteOverride(path: path, method: method.rawValue))
        apiHandlers.append(APIRouteHandler(path: path, method: method, handle: handle))
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
}

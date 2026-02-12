import Foundation

public enum CachePolicy: Sendable, Equatable {
    case noStore
    case staleWhileRevalidate(seconds: Int)
    case revalidateAfter(seconds: Int)
    case immutable
}

public enum RenderMode: Sendable, Equatable {
    case ssr
    case ssg
    case isr
}

public struct FetchPolicy: Sendable, Equatable {
    public var mode: RenderMode
    public var cache: CachePolicy

    public init(mode: RenderMode, cache: CachePolicy) {
        self.mode = mode
        self.cache = cache
    }

    public static let ssrNoStore = FetchPolicy(mode: .ssr, cache: .noStore)
    public static let ssgImmutable = FetchPolicy(mode: .ssg, cache: .immutable)
    public static let isr60s = FetchPolicy(mode: .isr, cache: .revalidateAfter(seconds: 60))
}

public struct FetchRequest: Sendable, Equatable {
    public var url: URL
    public var method: String
    public var headers: [String: String]
    public var body: Data?
    public var policy: FetchPolicy

    public init(
        url: URL,
        method: String = "GET",
        headers: [String: String] = [:],
        body: Data? = nil,
        policy: FetchPolicy = .ssrNoStore
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.policy = policy
    }
}

public struct FetchResponse: Sendable, Equatable {
    public var statusCode: Int
    public var headers: [String: String]
    public var body: Data

    public init(statusCode: Int, headers: [String: String] = [:], body: Data) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }

    public func decodeJSON<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = .init()) throws -> T {
        try decoder.decode(type, from: body)
    }
}

public protocol DataFetcher: Sendable {
    func fetch(_ request: FetchRequest) async throws -> FetchResponse
}

public actor InMemoryFetchCache {
    private struct Entry {
        let response: FetchResponse
        let expiration: Date?
    }

    private var storage: [String: Entry] = [:]

    public init() {}

    public func cachedResponse(for request: FetchRequest, now: Date = Date()) -> FetchResponse? {
        let key = cacheKey(for: request)
        guard let entry = storage[key] else { return nil }
        if let expiration = entry.expiration, expiration <= now {
            storage.removeValue(forKey: key)
            return nil
        }
        return entry.response
    }

    public func store(_ response: FetchResponse, for request: FetchRequest, now: Date = Date()) {
        let key = cacheKey(for: request)
        let expiration: Date?
        switch request.policy.cache {
        case .noStore:
            return
        case .immutable:
            expiration = nil
        case .staleWhileRevalidate(let seconds), .revalidateAfter(let seconds):
            expiration = now.addingTimeInterval(TimeInterval(seconds))
        }

        storage[key] = Entry(response: response, expiration: expiration)
    }

    private func cacheKey(for request: FetchRequest) -> String {
        "\(request.method):\(request.url.absoluteString):\(request.headers.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: "&"))"
    }
}

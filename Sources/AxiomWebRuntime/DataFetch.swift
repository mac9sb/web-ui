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
    public struct CachedResponseMetadata: Sendable, Equatable {
        public let cachedAt: Date
        public let expiresAt: Date?
        public let staleUntil: Date?

        public init(cachedAt: Date, expiresAt: Date?, staleUntil: Date?) {
            self.cachedAt = cachedAt
            self.expiresAt = expiresAt
            self.staleUntil = staleUntil
        }
    }

    public enum CacheLookupResult: Sendable, Equatable {
        case miss
        case fresh(FetchResponse)
        case stale(FetchResponse)
    }

    private struct Entry {
        let response: FetchResponse
        let cachedAt: Date
        let expiration: Date?
        let staleUntil: Date?
    }

    private var storage: [String: Entry] = [:]

    public init() {}

    public func cachedResponse(for request: FetchRequest, now: Date = Date()) -> FetchResponse? {
        switch lookup(request, now: now) {
        case .fresh(let response):
            return response
        case .miss, .stale:
            return nil
        }
    }

    public func lookup(_ request: FetchRequest, now: Date = Date()) -> CacheLookupResult {
        let key = cacheKey(for: request)
        guard let entry = storage[key] else {
            return .miss
        }

        if let expiration = entry.expiration, expiration <= now {
            if let staleUntil = entry.staleUntil, staleUntil > now {
                return .stale(entry.response)
            }
            storage.removeValue(forKey: key)
            return .miss
        }

        return .fresh(entry.response)
    }

    public func metadata(for request: FetchRequest) -> CachedResponseMetadata? {
        let key = cacheKey(for: request)
        guard let entry = storage[key] else {
            return nil
        }
        return CachedResponseMetadata(cachedAt: entry.cachedAt, expiresAt: entry.expiration, staleUntil: entry.staleUntil)
    }

    public func store(_ response: FetchResponse, for request: FetchRequest, now: Date = Date()) {
        let key = cacheKey(for: request)
        let expiration: Date?
        let staleUntil: Date?
        switch request.policy.cache {
        case .noStore:
            return
        case .immutable:
            expiration = nil
            staleUntil = nil
        case .revalidateAfter(let seconds):
            let normalized = max(1, seconds)
            expiration = now.addingTimeInterval(TimeInterval(normalized))
            staleUntil = nil
        case .staleWhileRevalidate(let seconds):
            let normalized = max(1, seconds)
            expiration = now.addingTimeInterval(TimeInterval(normalized))
            staleUntil = now.addingTimeInterval(TimeInterval(normalized * 2))
        }

        storage[key] = Entry(response: response, cachedAt: now, expiration: expiration, staleUntil: staleUntil)
    }

    public func remove(_ request: FetchRequest) {
        storage.removeValue(forKey: cacheKey(for: request))
    }

    private func cacheKey(for request: FetchRequest) -> String {
        "\(request.method):\(request.url.absoluteString):\(request.headers.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: "&"))"
    }
}

public actor FetchExecutor {
    private let fetcher: any DataFetcher
    private let cache: InMemoryFetchCache

    public init(fetcher: any DataFetcher, cache: InMemoryFetchCache = InMemoryFetchCache()) {
        self.fetcher = fetcher
        self.cache = cache
    }

    public func perform(_ request: FetchRequest, now: Date = Date()) async throws -> FetchResponse {
        switch request.policy.cache {
        case .noStore:
            return try await fetcher.fetch(request)
        default:
            break
        }

        switch await cache.lookup(request, now: now) {
        case .fresh(let response):
            return response
        case .stale(let response):
            refreshInBackground(request)
            return response
        case .miss:
            let response = try await fetcher.fetch(request)
            await cache.store(response, for: request, now: now)
            return response
        }
    }

    public func cachedMetadata(for request: FetchRequest) async -> InMemoryFetchCache.CachedResponseMetadata? {
        await cache.metadata(for: request)
    }

    private func refreshInBackground(_ request: FetchRequest) {
        Task {
            do {
                let response = try await fetcher.fetch(request)
                await cache.store(response, for: request)
            } catch {
                // Preserve stale response on refresh errors.
            }
        }
    }
}

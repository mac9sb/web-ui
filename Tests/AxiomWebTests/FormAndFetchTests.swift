import Foundation
import Testing
@testable import AxiomWebRuntime
@testable import AxiomWebUI

@Suite("Form and Fetch")
struct FormAndFetchTests {
    @Test("Validates typed form schema")
    func formSchemaValidation() {
        let schema = FormSchema([
            .init(field: .init(name: "email", type: .email, required: true)),
            .init(field: .init(name: "age", type: .number, required: false)),
        ])

        let errors = schema.validate(["email": "invalid-email", "age": "abc"])
        #expect(errors.contains(.invalidEmail("email")))
        #expect(errors.contains(.invalidNumber("age")))
    }

    @Test("Caches and expires fetched responses")
    func fetchCacheStoresAndExpires() async {
        let cache = InMemoryFetchCache()
        let request = FetchRequest(
            url: URL(string: "https://example.com/data")!,
            policy: .init(mode: .isr, cache: .revalidateAfter(seconds: 1))
        )
        let response = FetchResponse(statusCode: 200, body: Data("ok".utf8))

        await cache.store(response, for: request, now: Date(timeIntervalSince1970: 1000))

        let fresh = await cache.cachedResponse(for: request, now: Date(timeIntervalSince1970: 1000.5))
        #expect(fresh?.statusCode == 200)

        let expired = await cache.cachedResponse(for: request, now: Date(timeIntervalSince1970: 1002))
        #expect(expired == nil)
    }

    @Test("Fetch executor serves stale and revalidates in background")
    func fetchExecutorStaleWhileRevalidate() async throws {
        actor CountingFetcher: DataFetcher {
            var calls = 0

            func fetch(_ request: FetchRequest) async throws -> FetchResponse {
                calls += 1
                return FetchResponse(statusCode: 200, body: Data("value-\(calls)".utf8))
            }

            func callCount() -> Int { calls }
        }

        let fetcher = CountingFetcher()
        let cache = InMemoryFetchCache()
        let executor = FetchExecutor(fetcher: fetcher, cache: cache)
        let request = FetchRequest(
            url: URL(string: "https://example.com/stale")!,
            policy: .init(mode: .isr, cache: .staleWhileRevalidate(seconds: 1))
        )

        let first = try await executor.perform(request, now: Date(timeIntervalSince1970: 1000))
        #expect(String(data: first.body, encoding: .utf8) == "value-1")

        let stale = try await executor.perform(request, now: Date(timeIntervalSince1970: 1001.5))
        #expect(String(data: stale.body, encoding: .utf8) == "value-1")

        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(await fetcher.callCount() == 2)

        let refreshed = try await executor.perform(request, now: Date(timeIntervalSince1970: 1001.5))
        #expect(String(data: refreshed.body, encoding: .utf8) == "value-2")
    }
}

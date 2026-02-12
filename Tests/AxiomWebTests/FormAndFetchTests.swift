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
}

import Testing
@testable import AxiomWebUI
@testable import AxiomWebRender

@Suite("Structured Data")
struct StructuredDataTests {
    @Test("Validates required fields in strict mode")
    func validatesRequiredFieldsInStrictMode() throws {
        struct InvalidDoc: Document {
            var metadata: Metadata {
                Metadata(
                    title: "Invalid",
                    structuredData: [
                        .organization(.init(name: .init(""), url: ""))
                    ]
                )
            }

            var path: String { "/invalid" }

            var body: some Markup {
                Main { Text("Invalid") }
            }
        }

        do {
            _ = try RenderEngine.render(
                document: InvalidDoc(),
                locale: .en,
                options: .init(buildOptions: .init(structuredDataValidationMode: .strict))
            )
            #expect(Bool(false), "Expected strict structured-data validation to throw")
        } catch let error as RenderError {
            switch error {
            case .structuredDataValidationFailed(let validationError):
                #expect(validationError == .missingRequiredField(nodeType: "Organization", field: "url"))
            case .jsonEncodingFailed:
                #expect(Bool(false), "Expected validation failure but got JSON encoding failure")
            }
        }
    }

    @Test("Deduplicates by @id")
    func deduplicatesByID() {
        let graph = StructuredDataGraph([
            .website(.init(id: "urn:site", name: .init("Axiom"), url: "https://example.com")),
            .website(.init(id: "urn:site", name: .init("Axiom Duplicate"), url: "https://example.com/dup")),
        ]).deduplicated()

        #expect(graph.nodes.count == 1)
    }

    @Test("Renders JSON-LD graph script")
    func rendersJSONLDScript() throws {
        struct Doc: Document {
            var metadata: Metadata {
                Metadata(
                    title: "Home",
                    structuredData: [
                        .website(.init(id: "urn:site", name: .init("Axiom"), url: "https://example.com")),
                        .webPage(.init(id: "urn:home", name: .init("Home"), url: "https://example.com/")),
                    ]
                )
            }

            var path: String { "/" }

            var body: some Markup {
                Main { Text("Hello") }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.html.contains("application/ld+json"))
        #expect(rendered.html.contains("\"@graph\""))
        #expect(rendered.html.contains("\"@context\":\"https://schema.org\""))
    }
}

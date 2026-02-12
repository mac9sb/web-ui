import Testing
@testable import AxiomWebRender
@testable import AxiomWebUI

@Suite("Metadata Rendering")
struct MetadataRenderTests {
    @Test("Renders canonical and hreflang links")
    func rendersCanonicalAndHreflang() throws {
        struct Doc: Document {
            var metadata: Metadata {
                Metadata(
                    title: "Home",
                    canonicalURL: "https://example.com/",
                    alternateURLs: [
                        .en: "https://example.com/",
                        "fr": "https://example.com/fr/"
                    ]
                )
            }

            var path: String { "/" }

            var body: some Markup {
                Main { Text("hello") }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.html.contains("rel=\"canonical\""))
        #expect(rendered.html.contains("hreflang=\"en\""))
        #expect(rendered.html.contains("hreflang=\"fr\""))
    }
}

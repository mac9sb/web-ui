import Testing
@testable import AxiomWebUI
@testable import AxiomWebRender

@Suite("Text Rendering")
struct TextRenderingTests {
    @Test("Short text renders with span tag by default")
    func shortTextUsesSpan() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "Home") }
            var path: String { "/" }
            var body: some Markup {
                Main { Text("Hello") }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.html.contains("<span>Hello</span>"))
    }

    @Test("Long text renders with paragraph tag by default")
    func longTextUsesParagraph() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "Home") }
            var path: String { "/" }
            var body: some Markup {
                Main {
                    Text("This sentence is intentionally long so Text picks paragraph rendering by default.")
                }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.html.contains("<p>This sentence is intentionally long so Text picks paragraph rendering by default.</p>"))
    }

    @Test("Raw text bypasses automatic wrapping")
    func rawTextBypassesTagWrapping() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "Home") }
            var path: String { "/" }
            var body: some Markup {
                Main { Text.raw("plain") }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.html.contains("<main>plain</main>"))
    }
}

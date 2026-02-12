import Testing
@testable import AxiomWebRender
@testable import AxiomWebMarkdown
@testable import AxiomWebUI
@testable import AxiomWebUIComponents

@Suite("Components and Markdown")
struct ComponentsAndMarkdownTests {
    @Test("Native-first components emit semantic HTML primitives")
    func nativeFirstComponentsEmitSemanticHTML() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "Components") }
            var path: String { "/" }

            var body: some Markup {
                Main {
                    Card {
                        Badge("Beta", tone: .accent)
                        Alert(title: "Heads up", message: "A new feature is available.", tone: .info)
                    }

                    Accordion {
                        AccordionItem("What is AxiomWeb?") {
                            Paragraph("A Swift-first web framework.")
                        }
                    }

                    Popover(id: "help-popover", triggerLabel: "Open Help") {
                        Paragraph("Popover content")
                    }

                    ModalDialog(id: "confirm-dialog", triggerLabel: "Open Dialog") {
                        Paragraph("Confirm this action?")
                    }

                    DropdownMenu(label: "Actions") {
                        Link("Edit", href: "/edit")
                        Link("Delete", href: "/delete")
                    }
                }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.html.contains("<details"))
        #expect(rendered.html.contains("popover"))
        #expect(rendered.html.contains("commandfor=\"confirm-dialog\""))
        #expect(rendered.html.contains("<dialog"))
    }

    @Test("WasmCanvas emits typed wasm binding attributes and fallback")
    func wasmCanvasEmitsBindingsAndFallback() {
        let component = WasmCanvas(
            id: "render-canvas",
            modulePath: "/assets/wasm/renderer.mjs",
            mountExport: "mount",
            initialPayload: .object([
                "seed": .int(42),
                "label": .string("demo"),
            ])
        )

        let html = component.renderHTML()
        #expect(html.contains("data-ax-wasm-module=\"/assets/wasm/renderer.mjs\""))
        #expect(html.contains("data-ax-wasm-mount=\"mount\""))
        #expect(html.contains("data-ax-wasm-initial="))
        #expect(html.contains("data-ax-wasm-fallback-for=\"render-canvas\""))
    }

    @Test("Markdown renderer supports styling, admonitions, lists, and code blocks")
    func markdownRendererSupportsStylingAdmonitionsListsAndCodeBlocks() {
        let markdown = """
# Title

> [!NOTE] Heads up
> This is an admonition body.

- one
- two

Inline `code` sample.

```swift
let value = 1
```
"""

        let rendered = MarkdownRenderer.render(markdown)
        let html = rendered.renderHTML()

        #expect(html.contains("class=\"markdown-content\""))
        #expect(html.contains("class=\"admonition admonition-note\""))
        #expect(html.contains("<ul"))
        #expect(html.contains("class=\"markdown-inline-code\""))
        #expect(html.contains("class=\"markdown-code language-swift\""))
    }
}

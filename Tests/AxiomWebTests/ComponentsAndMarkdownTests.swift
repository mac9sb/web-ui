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

                    NavigationMenu(items: [
                        .init("Home", href: "/", current: true),
                        .init("Docs", href: "/docs"),
                    ])

                    Breadcrumbs(items: [
                        .init("Home", href: "/"),
                        .init("Settings", href: "/settings"),
                        .init("Profile", current: true),
                    ])

                    Pagination(currentPage: 2, totalPages: 4, basePath: "/blog")

                    ProgressBar(value: 64, maximum: 100, label: "Build Progress")

                    Separator()

                    Collapsible(title: "Advanced Settings") {
                        Paragraph("Additional controls")
                    }

                    ScrollArea(maxHeight: .length(8, .rem)) {
                        for index in 1...4 {
                            Paragraph("Scrollable item \(index)")
                        }
                    }

                    AspectRatioFrame(width: 4, height: 3) {
                        Stack {
                            Text("Aspect ratio content")
                        }
                        .background(color: .stone(100))
                    }

                    Avatar(imageURL: "/avatar.png", alt: "Profile image", fallbackText: "AW")

                    Skeleton(width: .length(10, .rem), height: .length(1.25, .rem))

                    CheckboxField(id: "release-check", name: "release", label: "Ship release", checked: true)
                    SwitchField(id: "metrics-switch", name: "metrics", label: "Enable metrics", on: true)

                    SelectField(
                        label: "Framework",
                        name: "framework",
                        options: [
                            .init(value: "axiom", label: "AxiomWeb", selected: true),
                            .init(value: "other", label: "Other"),
                        ]
                    )

                    DataTable(
                        columns: ["Name", "Role"],
                        rows: [
                            .init(["Morgan", "Developer"]),
                            .init(["Sam", "Designer"]),
                        ],
                        caption: "Team"
                    )

                    Tabs(items: [
                        .init(id: "overview", title: "Overview") {
                            Paragraph("Overview content")
                        },
                        .init(id: "activity", title: "Activity") {
                            Paragraph("Activity content")
                        },
                    ])

                    Tooltip("Helpful hint") {
                        Text("Hover target")
                    }

                    ToastMessage(title: "Saved", message: "Settings were updated.")

                    SheetPanel(id: "settings-sheet", triggerLabel: "Open Sheet", side: .right) {
                        Paragraph("Sheet content")
                    }

                    CommandPalette(
                        id: "command-palette",
                        commands: [
                            .init(value: "open", label: "Open Project"),
                            .init(value: "build", label: "Build Site"),
                        ]
                    )
                }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.html.contains("<details"))
        #expect(rendered.html.contains("popover"))
        #expect(rendered.html.contains("commandfor=\"confirm-dialog\""))
        #expect(rendered.html.contains("<dialog"))
        #expect(rendered.html.contains("aria-label=\"Primary Navigation\""))
        #expect(rendered.html.contains("aria-label=\"Breadcrumb\""))
        #expect(rendered.html.contains("aria-label=\"Pagination\""))
        #expect(rendered.html.contains("<progress"))
        #expect(rendered.html.contains("role=\"separator\""))
        #expect(rendered.html.contains("data-ax-component=\"collapsible\""))
        #expect(rendered.html.contains("data-ax-component=\"scroll-area\""))
        #expect(rendered.html.contains("data-ax-component=\"aspect-ratio\""))
        #expect(rendered.html.contains("<table"))
        #expect(rendered.html.contains("role=\"switch\""))
        #expect(rendered.html.contains("<select"))
        #expect(rendered.html.contains("aria-label=\"Tabs\""))
        #expect(rendered.html.contains("title=\"Helpful hint\""))
        #expect(rendered.html.contains("role=\"status\""))
        #expect(rendered.html.contains("commandfor=\"settings-sheet\""))
        #expect(rendered.html.contains("id=\"command-palette-list\""))
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

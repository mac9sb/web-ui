import Testing
@testable import AxiomWebCodegen
@testable import AxiomWebRender
@testable import AxiomWebStyle
@testable import AxiomWebUI

@Suite("CSS Coverage")
struct CSSCoverageTests {
    @Test("CSS property members align to spec snapshot")
    func cssMembersAlignToSpecSnapshot() {
        let snapshot = CodegenSpecRegistry.builtinSnapshot(for: .cssProperties)
        #expect(Set(snapshot.entries) == CSSPropertyCatalog.supportedNames)
        #expect(CSSProperty.dslCoveredNames == CSSPropertyCatalog.supportedNames)
    }

    @Test("Supports arbitrary typed CSS declarations")
    func supportsArbitraryTypedCSSDeclarations() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "CSS") }
            var path: String { "/" }

            var body: some Markup {
                Stack {
                    Text("Grid")
                }
                .css(.gridTemplateColumns, .raw("1fr 2fr"))
                .css("backdrop-filter", .raw("blur(6px)"))
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.css.contains("grid-template-columns:1fr 2fr"))
        #expect(rendered.css.contains("backdrop-filter:blur(6px)"))
    }

    @Test("Supports arbitrary CSS inside responsive/state variants")
    func supportsArbitraryCSSInVariants() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "Variant CSS") }
            var path: String { "/" }

            var body: some Markup {
                Stack { Text("Variant") }
                    .on {
                        $0.md {
                            $0.css(.transform, .raw("translateY(-2px)"))
                        }
                        $0.dark {
                            $0.css(.opacity, .number(0.9))
                        }
                    }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.css.contains("transform:translateY(-2px)"))
        #expect(rendered.css.contains("opacity:0.9"))
        #expect(rendered.css.contains("@media (min-width: 768px)"))
        #expect(rendered.css.contains("@media (prefers-color-scheme: dark)"))
    }

    @Test("Generated property members are usable in DSL")
    func generatedPropertyMembersAreUsableInDSL() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "Member CSS") }
            var path: String { "/" }

            var body: some Markup {
                Stack { Text("Props") }
                    .backdropFilter(.raw("blur(4px)"))
                    .containerType(.keyword("inline-size"))
                    .scrollbarColor(.raw("auto"))
                    .on {
                        $0.md {
                            $0.gridTemplateColumns(.raw("1fr 2fr"))
                        }
                        $0.dark {
                            $0.textDecorationStyle(.keyword("wavy"))
                        }
                    }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.css.contains("backdrop-filter:blur(4px)"))
        #expect(rendered.css.contains("container-type:inline-size"))
        #expect(rendered.css.contains("scrollbar-color:auto"))
        #expect(rendered.css.contains("grid-template-columns:1fr 2fr"))
        #expect(rendered.css.contains("text-decoration-style:wavy"))
    }
}

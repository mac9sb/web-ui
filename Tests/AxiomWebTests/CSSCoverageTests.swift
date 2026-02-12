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

    @Test("Property members are usable in DSL")
    func propertyMembersAreUsableInDSL() throws {
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

    @Test("Fluent animation emits declarations with trigger variants and keyframes")
    func fluentAnimationEmitsTriggeredDeclarationsAndKeyframes() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "Animation") }
            var path: String { "/" }

            var body: some Markup {
                Stack { Text("Animated") }
                    .animate(.fadeIn, duration: 0.4, timing: .easeInOut)
                    .on {
                        $0.hover {
                            $0.animate(
                                .custom(
                                    name: "lift-in",
                                    frames: [
                                        AnimationFrame(
                                            selector: .from,
                                            declarations: [
                                                .init(property: .opacity, value: .number(0)),
                                                .init(property: .transform, value: .raw("translateY(0.75rem)")),
                                            ]
                                        ),
                                        AnimationFrame(
                                            selector: .to,
                                            declarations: [
                                                .init(property: .opacity, value: .number(1)),
                                                .init(property: .transform, value: .raw("translateY(0)")),
                                            ]
                                        ),
                                    ]
                                ),
                                duration: 0.6,
                                timing: .easeOut
                            )
                        }
                    }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.css.contains("animation:ax-fade-in 0.4s ease-in-out 0s 1 normal both running"))
        #expect(rendered.css.contains("@keyframes ax-fade-in"))
        #expect(rendered.css.contains(":hover{animation:ax-lift-in 0.6s ease-out 0s 1 normal both running"))
        #expect(rendered.css.contains("animation:ax-lift-in 0.6s ease-out 0s 1 normal both running"))
        #expect(rendered.css.contains("@keyframes ax-lift-in"))
    }

    @Test("Starting style is inferred automatically when animation is applied")
    func startingStyleDeclarationsAreInferredAutomatically() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "Starting Style") }
            var path: String { "/" }

            var body: some Markup {
                Stack { Text("Start") }
                    .animate(.slideUp, duration: 0.35)
                    .on {
                        $0.md {
                            $0.animate(.fadeIn, duration: 0.2)
                        }
                    }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.css.contains("@starting-style{.axs-"))
        #expect(rendered.css.contains("opacity:0"))
        #expect(rendered.css.contains("transform:translateY(0.5rem)"))
        #expect(rendered.css.contains("@media (min-width: 768px){@starting-style"))
    }
}

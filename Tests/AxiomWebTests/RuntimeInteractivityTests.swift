import Testing
@testable import AxiomWebRender
@testable import AxiomWebRuntime
@testable import AxiomWebStyle
@testable import AxiomWebUI

@Suite("Runtime Interactivity")
struct RuntimeInteractivityTests {
    @Test("Emits DOM runtime bindings from .on style block")
    func emitsDOMRuntimeBindingsFromOnBlock() throws {
        struct Doc: Document {
            @State("count") var count = 0

            var metadata: Metadata { Metadata(title: "Counter") }
            var path: String { "/" }

            var body: some Markup {
                Button("Increment")
                    .on {
                        $0.md {
                            $0.background(color: .blue(600))
                        }
                        $0.click {
                            $0.increment($count)
                        }
                    }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.html.contains("data-ax-states="))
        #expect(rendered.html.contains("data-ax-on-click="))
        #expect(rendered.html.contains("md:bg-blue-600"))
        #expect(rendered.javascript.contains("__axSelector"))
    }

    @Test("Merges document runtime program with rendered output")
    func mergesDocumentRuntimeProgram() throws {
        struct Doc: Document, RuntimeProgramProviding {
            @State("ticks") var ticks = 0

            var metadata: Metadata { Metadata(title: "Ticker") }
            var path: String { "/" }

            var runtimeProgram: RuntimeProgram {
                RuntimeProgram {
                    Runtime.state($ticks)
                    Runtime.every(seconds: 1, perform: Runtime.increment($ticks))
                }
            }

            var body: some Markup {
                Main { Text("Tick") }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.javascript.contains("setInterval"))
        #expect(rendered.javascript.contains("ticks"))
    }

    @Test("Supports wasm invocation actions from .on interaction blocks")
    func supportsWasmInvocationActionsFromOnBlocks() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "Wasm Action") }
            var path: String { "/" }

            var body: some Markup {
                Button("Invoke")
                    .on {
                        $0.click {
                            $0.invokeWasm(
                                on: "render-canvas",
                                export: "tick",
                                payload: .object(["step": .int(1), "debug": .bool(true)])
                            )
                        }
                    }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.html.contains("data-ax-on-click="))
        #expect(rendered.javascript.contains("AxiomWasm.invoke"))
    }

    @Test("Includes wasm DOM bootstrap when wasm canvas bindings are present")
    func includesWasmDOMBootstrapWhenBindingsArePresent() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "Wasm Canvas") }
            var path: String { "/" }

            var body: some Markup {
                Node("canvas", attributes: [
                    HTMLAttribute("id", "render-canvas"),
                    HTMLAttribute(WasmDOMCodec.moduleAttribute, "/assets/wasm/renderer.mjs"),
                ])
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.javascript.contains("__ax_wasm_booted"))
        #expect(rendered.javascript.contains("AxiomWasm.invoke"))
    }
}

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
}

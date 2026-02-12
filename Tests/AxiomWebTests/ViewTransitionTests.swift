import Foundation
import Testing
@testable import AxiomWebRender
@testable import AxiomWebServer
@testable import AxiomWebStyle
@testable import AxiomWebUI

@Suite("View Transitions")
struct ViewTransitionTests {
    @Test("Document-level view transition emits typed CSS and runtime navigation wrapping")
    func documentLevelViewTransitionEmission() throws {
        struct Doc: Document, ViewTransitionProviding {
            var metadata: Metadata { Metadata(title: "View Transition") }
            var path: String { "/" }

            var viewTransition: ViewTransitionConfiguration {
                ViewTransitionConfiguration(
                    navigation: .auto,
                    runtimeNavigation: true,
                    durationSeconds: 0.45,
                    timing: .easeInOut
                )
            }

            var body: some Markup {
                Button("Go")
                    .viewTransitionName("card")
                    .on {
                        $0.click {
                            $0.navigate(to: "/next")
                        }
                    }
            }
        }

        let rendered = try RenderEngine.render(document: Doc(), locale: .en)
        #expect(rendered.html.contains("@view-transition{navigation:auto}"))
        #expect(rendered.html.contains("::view-transition-old(root),::view-transition-new(root)"))
        #expect(rendered.html.contains("prefers-reduced-motion: reduce"))
        #expect(rendered.javascript.contains("document.startViewTransition"))
        #expect(rendered.css.contains("view-transition-name:card"))
    }

    @Test("Render parameter view transition applies when document does not provide one")
    func renderParameterViewTransitionApplies() throws {
        struct Doc: Document {
            var metadata: Metadata { Metadata(title: "View Transition Override") }
            var path: String { "/" }

            var body: some Markup {
                Button("Go")
                    .on {
                        $0.click {
                            $0.navigate(to: "/next")
                        }
                    }
            }
        }

        let rendered = try RenderEngine.render(
            document: Doc(),
            locale: .en,
            viewTransition: .init(
                navigation: .none,
                runtimeNavigation: false,
                applyRootAnimation: false
            )
        )

        #expect(rendered.html.contains("@view-transition{navigation:none}"))
        #expect(rendered.html.contains("::view-transition-old(root)") == false)
        #expect(rendered.javascript.contains("document.startViewTransition") == false)
    }

    @Test("Static build uses website-level view transition and page-level override")
    func staticBuildResolvesWebsiteAndPageViewTransitions() throws {
        struct HomeDoc: Document {
            var metadata: Metadata { Metadata(title: "Home") }
            var path: String { "/" }

            var body: some Markup {
                Main { Text("home") }
            }
        }

        struct DetailDoc: Document, ViewTransitionProviding {
            var metadata: Metadata { Metadata(title: "Detail") }
            var path: String { "/detail" }

            var viewTransition: ViewTransitionConfiguration {
                .init(navigation: .none, runtimeNavigation: false, applyRootAnimation: false)
            }

            var body: some Markup {
                Main { Text("detail") }
            }
        }

        struct Site: Website, ViewTransitionProviding {
            var metadata: Metadata { Metadata(site: "Axiom") }
            var viewTransition: ViewTransitionConfiguration {
                .init(navigation: .auto, runtimeNavigation: true)
            }

            var routes: [any Document] {
                [HomeDoc(), DetailDoc()]
            }
        }

        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-view-transition-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        _ = try StaticSiteBuilder(
            configuration: .init(
                routesRoot: routesRoot,
                outputDirectory: outputRoot,
                assetsSourceDirectory: assetsRoot,
                website: Site(),
                buildMode: .staticSite
            )
        ).build()

        let homeHTML = try String(contentsOfFile: outputRoot.appending(path: "index.html").path(), encoding: .utf8)
        let detailHTML = try String(contentsOfFile: outputRoot.appending(path: "detail/index.html").path(), encoding: .utf8)
        #expect(homeHTML.contains("@view-transition{navigation:auto}"))
        #expect(detailHTML.contains("@view-transition{navigation:none}"))
    }
}


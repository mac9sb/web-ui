import Testing
@testable import AxiomWebUI

@Suite("HTML Coverage")
struct HTMLCoverageTests {
    @Test("Tag enum aligns to DSL coverage registry")
    func tagEnumAlignsToDSLCoverageRegistry() {
        #expect(HTMLTagName.supportedNames == HTMLTagName.dslCoveredNames)
    }

    @Test("Typed DSL source coverage matches HTML tag enum")
    func dslSourceCoverageMatchesHTMLTagEnum() throws {
        let packageRoot = SourceParitySupport.packageRoot()
        let elementsRoot = packageRoot.appending(path: "Sources/AxiomWebUI/Elements")
        let files = try SourceParitySupport.swiftFileContents(in: elementsRoot)

        var discovered: Set<String> = []
        for source in files.values {
            let enumBackedTags = SourceParitySupport.allMatches(
                pattern: #"tagName\s*:\s*HTMLTagName\s*=\s*\.(`?[A-Za-z0-9_]+`?)"#,
                in: source
            ).map { $0.replacingOccurrences(of: "`", with: "") }

            let explicitElementTags = SourceParitySupport.allMatches(
                pattern: #"HTMLElementNode\s*\(\s*tag:\s*"([a-z0-9]+)""#,
                in: source
            )

            let nodeTags = SourceParitySupport.allMatches(
                pattern: #"Node\s*\(\s*"([a-z0-9]+)""#,
                in: source
            )

            discovered.formUnion(enumBackedTags)
            discovered.formUnion(explicitElementTags)
            discovered.formUnion(nodeTags)
        }

        #expect(discovered == HTMLTagName.supportedNames)
    }

    @Test("Tag enum includes modern broad HTML coverage")
    func tagEnumIncludesModernBroadCoverage() {
        let tags = HTMLTagName.supportedNames

        #expect(tags.contains("article"))
        #expect(tags.contains("dialog"))
        #expect(tags.contains("details"))
        #expect(tags.contains("template"))
        #expect(tags.contains("track"))
        #expect(tags.contains("wbr"))
        #expect(tags.count > 100)
    }

    @Test("Supports rendering advanced tags via DSL members")
    func supportsAdvancedTagRenderingViaMembers() {
        let markup = Article {
            H1 { "Coverage" }
            Dialog(attributes: [HTMLAttribute("open")]) {
                Blockquote {
                    Abbreviation {
                        "Hello"
                    }
                }
            }
            Area(attributes: [HTMLAttribute("shape", "rect"), HTMLAttribute("coords", "0,0,10,10")])
            Image(attributes: [HTMLAttribute("src", "/hero.png"), HTMLAttribute("alt", "Hero")])
        }

        let html = markup.renderHTML()
        #expect(html.contains("<article>"))
        #expect(html.contains("<h1>Coverage</h1>"))
        #expect(html.contains("<dialog open>"))
        #expect(html.contains("<blockquote>"))
        #expect(html.contains("<abbr>Hello</abbr>"))
        #expect(html.contains("<area shape=\"rect\" coords=\"0,0,10,10\">"))
        #expect(html.contains("<img src=\"/hero.png\" alt=\"Hero\">"))
    }

    @Test("HTML tag enum is deterministic and unique")
    func htmlTagEnumIsDeterministicAndUnique() {
        let entries = HTMLTagName.allCases.map(\.rawValue)
        #expect(entries.sorted() == entries)
        #expect(Set(entries).count == entries.count)
    }
}

import Testing
@testable import AxiomWebCodegen
@testable import AxiomWebUI

@Suite("HTML Coverage")
struct HTMLCoverageTests {
    @Test("Tag enum aligns to HTML spec snapshot")
    func tagEnumAlignsToSpecSnapshot() {
        let snapshot = CodegenSpecRegistry.builtinSnapshot(for: .htmlElements)
        let tags = Set(snapshot.entries)
        #expect(tags == HTMLTagName.supportedNames)
    }

    @Test("DSL members cover every HTML tag")
    func dslMembersCoverEveryHTMLTag() {
        #expect(HTMLTagName.dslCoveredNames == HTMLTagName.supportedNames)
    }

    @Test("Snapshot includes modern broad HTML coverage")
    func snapshotIncludesModernBroadCoverage() {
        let tags = Set(CodegenSpecRegistry.builtinSnapshot(for: .htmlElements).entries)

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

    @Test("HTML snapshot is deterministic and unique")
    func snapshotIsDeterministicAndUnique() {
        let snapshot = CodegenSpecRegistry.builtinSnapshot(for: .htmlElements)
        #expect(snapshot.version == "baseline-2026-02-12")
        #expect(snapshot.entries == snapshot.entries.sorted())
        #expect(Set(snapshot.entries).count == snapshot.entries.count)
    }
}

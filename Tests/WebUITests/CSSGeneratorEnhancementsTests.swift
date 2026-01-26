import Foundation
import Testing

@testable import WebUI

@Suite("CSS Generator Enhancements Tests", .serialized)
struct CSSGeneratorEnhancementsTests {

    @Test("Truncate utility generates correct CSS")
    func truncateUtility() {
        let classes = ["truncate"]
        let css = CSSGenerator.generateCSS(for: classes)

        #expect(css.contains("overflow: hidden"))
        #expect(css.contains("text-overflow: ellipsis"))
        #expect(css.contains("white-space: nowrap"))
    }

    @Test("Text overflow utilities generate correct CSS")
    func textOverflowUtilities() {
        let classes = ["text-ellipsis", "text-clip"]
        let css = CSSGenerator.generateCSS(for: classes)

        #expect(css.contains("text-overflow: ellipsis"))
        #expect(css.contains("text-overflow: clip"))
    }

    @Test("Grid columns with arbitrary values generate correct CSS")
    func gridColsArbitraryValues() {
        let classes = ["grid-cols-[40px_70px_1fr]"]
        let css = CSSGenerator.generateCSS(for: classes)

        // Should convert underscores to spaces
        #expect(css.contains("grid-template-columns: 40px 70px 1fr"))
    }

    @Test("Grid columns with numeric values still work")
    func gridColsNumericValues() {
        let classes = ["grid-cols-3"]
        let css = CSSGenerator.generateCSS(for: classes)

        #expect(css.contains("grid-template-columns: repeat(3, minmax(0, 1fr))"))
    }

    @Test("Grid columns with complex arbitrary values")
    func gridColsComplexArbitraryValues() {
        let classes = ["grid-cols-[40px_70px_60px_50px_1fr]"]
        let css = CSSGenerator.generateCSS(for: classes)

        #expect(css.contains("grid-template-columns: 40px 70px 60px 50px 1fr"))
    }

    @Test("Grid rows with arbitrary values generate correct CSS")
    func gridRowsArbitraryValues() {
        let classes = ["grid-rows-[100px_1fr_100px]"]
        let css = CSSGenerator.generateCSS(for: classes)

        #expect(css.contains("grid-template-rows: 100px 1fr 100px"))
    }

    @Test("ClassCollector safelist functionality")
    func classCollectorSafelist() {
        ClassCollector.shared.clearAll()
        defer { ClassCollector.shared.clearAll() }

        // Add some normal classes
        ClassCollector.shared.addClasses(["bg-blue-500", "p-4"])

        // Add safelist classes
        ClassCollector.shared.addSafelistClasses(["log-source", "log-message"])

        let allClasses = ClassCollector.shared.getClasses()

        #expect(allClasses.contains("bg-blue-500"))
        #expect(allClasses.contains("p-4"))
        #expect(allClasses.contains("log-source"))
        #expect(allClasses.contains("log-message"))

        // Clear collected classes but not safelist
        ClassCollector.shared.clear()
        let afterClear = ClassCollector.shared.getClasses()

        #expect(!afterClear.contains("bg-blue-500"))
        #expect(!afterClear.contains("p-4"))
        #expect(afterClear.contains("log-source"))
        #expect(afterClear.contains("log-message"))

        // Clear all
        ClassCollector.shared.clearAll()
        let afterClearAll = ClassCollector.shared.getClasses()

        #expect(afterClearAll.isEmpty)
    }

    @Test("Safelist classes generate CSS even without markup usage")
    func safelistGeneratesCSS() {
        // Start with a complete clean slate
        ClassCollector.shared.clearAll()
        defer { ClassCollector.shared.clearAll() }

        // Add only safelist classes
        ClassCollector.shared.addSafelistClasses(["truncate", "log-source"])

        // Verify they were added
        let classes = ClassCollector.shared.getClasses()
        #expect(classes.contains("truncate"))
        #expect(classes.contains("log-source"))

        let css = ClassCollector.shared.generateCSS()

        // truncate should generate CSS
        #expect(css.contains("overflow: hidden"))

        // Clean up
        ClassCollector.shared.clearAll()
    }

    @Test("Multiple grid arbitrary value patterns")
    func multipleGridArbitraryPatterns() {
        let classes = [
            "grid-cols-[70px_60px_50px_1fr]",
            "grid-cols-[40px_70px_60px_50px_1fr]",
            "grid-rows-[auto_1fr_auto]",
        ]
        let css = CSSGenerator.generateCSS(for: classes)

        #expect(css.contains("grid-template-columns: 70px 60px 50px 1fr"))
        #expect(css.contains("grid-template-columns: 40px 70px 60px 50px 1fr"))
        #expect(css.contains("grid-template-rows: auto 1fr auto"))
    }
}

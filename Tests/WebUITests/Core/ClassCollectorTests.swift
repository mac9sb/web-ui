import Foundation
import Testing

@testable import WebUI

@Suite("ClassCollector Tests")
struct ClassCollectorTests {
    @Test("Classes passed via classes parameter are collected")
    func testClassesParameterCollectsClasses() async throws {
        // Clear any previous state
        ClassCollector.shared.clear()

        // Create elements with classes parameter
        let stack = Stack(classes: ["flex", "gap-4", "p-2"])
        let button = Button("Click Me", classes: ["btn", "btn-primary"])
        let link = Link("Home", to: "/", classes: ["nav-link"])

        // Render elements to trigger class collection
        _ = stack.render()
        _ = button.render()
        _ = link.render()

        // Get collected classes
        let collected = ClassCollector.shared.getClasses()

        // Verify all classes were collected
        #expect(collected.contains("flex"))
        #expect(collected.contains("gap-4"))
        #expect(collected.contains("p-2"))
        #expect(collected.contains("btn"))
        #expect(collected.contains("btn-primary"))
        #expect(collected.contains("nav-link"))
    }

    @Test("SSRBuilder generates CSS for classes passed via classes parameter")
    func testSSRBuilderGeneratesCSSForClassesParameter() async throws {
        // Create a test document with elements using classes parameter
        struct TestPage: Document {
            var path: String { "test" }
            var metadata: Metadata {
                Metadata(title: "Test", description: "Test")
            }

            var body: some Markup {
                Stack(classes: ["custom-container", "bg-blue"]) {
                    Button("Submit", classes: ["btn-submit"])
                    Link("Home", to: "/", classes: ["link-home"])
                }
            }
        }

        // Clear previous state
        ClassCollector.shared.clear()

        // Render the page body (simulating what SSRBuilder does)
        let page = TestPage()
        _ = page.body.render()

        // Get collected classes
        let collected = ClassCollector.shared.getClasses()

        // Verify classes were collected
        #expect(collected.contains("custom-container"))
        #expect(collected.contains("bg-blue"))
        #expect(collected.contains("btn-submit"))
        #expect(collected.contains("link-home"))

        // Verify CSS can be generated
        let css = ClassCollector.shared.generateCSS()
        #expect(!css.isEmpty, "CSS should be generated for collected classes")
    }

    @Test("Classes from both parameter and modifiers are collected")
    func testClassesFromParameterAndModifiersCollected() async throws {
        ClassCollector.shared.clear()

        // Create element with classes parameter AND modifiers
        let element = Stack(classes: ["custom-class"])
            .padding(of: 4)
            .background(color: .blue(._500))

        _ = element.render()

        let collected = ClassCollector.shared.getClasses()

        // Verify both parameter classes and modifier classes are collected
        #expect(collected.contains("custom-class"))
        #expect(collected.contains("p-4"))
        #expect(collected.contains("bg-blue-500"))
    }

    @Test("Empty classes array does not cause issues")
    func testEmptyClassesArray() async throws {
        ClassCollector.shared.clear()

        let element = Stack(classes: [])
        _ = element.render()

        let collected = ClassCollector.shared.getClasses()
        #expect(collected.isEmpty)
    }

    @Test("Nil classes parameter does not cause issues")
    func testNilClassesParameter() async throws {
        ClassCollector.shared.clear()

        let element = Stack(classes: nil)
        _ = element.render()

        let collected = ClassCollector.shared.getClasses()
        #expect(collected.isEmpty)
    }

    @Test("Duplicate classes across elements are deduplicated")
    func testDuplicateClassesDeduplicated() async throws {
        ClassCollector.shared.clear()

        let element1 = Stack(classes: ["flex", "gap-4"])
        let element2 = Stack(classes: ["flex", "gap-4"])
        let element3 = Stack(classes: ["flex"])

        _ = element1.render()
        _ = element2.render()
        _ = element3.render()

        let collected = ClassCollector.shared.getClasses()

        // Should only have unique classes
        #expect(collected.contains("flex"))
        #expect(collected.contains("gap-4"))
        #expect(collected.count == 2)
    }
}

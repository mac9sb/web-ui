import Foundation
import Testing
import WebUIBrowserTesting

@Suite("WebUIBrowserTesting Tests")
struct WebUIBrowserTestingTests {
    @Test("Builds a basic browser test plan")
    func testBuildsPlan() {
        let plan = BrowserTest("Smoke") {
            Navigate(to: "about:blank")
            AssertView {
                Text("Hello")
            }
        }

        #expect(plan.name == "Smoke")
        #expect(!plan.steps.isEmpty)
    }
}

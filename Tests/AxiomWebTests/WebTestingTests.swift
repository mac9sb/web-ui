import Testing
@testable import AxiomWebTesting
@testable import AxiomWebUI

@Suite("Web Testing")
struct WebTestingTests {
    @Test("Snapshot comparison can normalize inter-tag whitespace")
    func snapshotNormalization() {
        let expected = "<div><span>Hello</span></div>"
        let actual = "<div>\n  <span>Hello</span>\n</div>"

        let result = SnapshotTesting.compare(expected: expected, actual: actual)
        #expect(result.matched)
    }

    @Test("Component snapshot renders markup")
    func componentSnapshotRendersMarkup() {
        let html = ComponentSnapshot.render(
            Stack {
                Paragraph("Hello")
            }
        )
        #expect(html.contains("<div>"))
        #expect(html.contains("<p>Hello</p>"))
    }

    @Test("Accessibility audit reports additional core issues")
    func accessibilityAuditReportsCoreIssues() {
        let html = "<html><body><button></button><div tabindex=\"2\"></div><style>.box{animation:spin 1s linear infinite;}</style></body></html>"
        let issues = AccessibilityAuditRunner.audit(html: html)

        #expect(issues.contains(.missingMainLandmark))
        #expect(issues.contains(.buttonMissingAccessibleName))
        #expect(issues.contains(.missingHTMLLang))
        #expect(issues.contains(.positiveTabIndexDetected))
        #expect(issues.contains(.motionWithoutReducedMotionFallback))
    }
}

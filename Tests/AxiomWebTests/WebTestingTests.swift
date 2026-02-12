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

    @Test("Accessibility audit report includes role and contrast findings")
    func accessibilityAuditReportIncludesRoleAndContrastFindings() {
        let html = """
<html lang="en">
<body>
  <main>
    <div role="badrole" style="color:#777777;background-color:#888888">Low contrast text</div>
    <style>:focus { outline: none; }</style>
  </main>
</body>
</html>
"""

        let report = AccessibilityAuditRunner.auditReport(html: html)
        #expect(report.findings.contains { $0.issue == .invalidARIArole })
        #expect(report.findings.contains { $0.issue == .lowContrastText })
        #expect(report.findings.contains { $0.issue == .focusStyleRemoved })
    }

    @Test("Accessibility CI reporter can emit markdown and json")
    func accessibilityCIReporterEmitsMarkdownAndJSON() {
        let report = AccessibilityAuditReport(findings: [
            AccessibilityFinding(
                issue: .missingMainLandmark,
                severity: .warning,
                message: "Missing main",
                selector: "main"
            )
        ])

        let markdown = AccessibilityCIReporter.render(report, format: .markdown)
        #expect(markdown.contains("## Accessibility Audit"))
        #expect(markdown.contains("missingMainLandmark"))

        let json = AccessibilityCIReporter.render(report, format: .json)
        #expect(json.contains("\"missingMainLandmark\""))
        #expect(json.contains("\"warning\""))
    }

    @Test("Snapshot suite supports named baseline comparison")
    func snapshotSuiteSupportsNamedBaselines() {
        var suite = SnapshotSuite()
        suite.record(name: "card", baseline: "<div><p>Hello</p></div>")

        let matched = suite.compare(name: "card", actual: "<div>\n <p>Hello</p>\n</div>")
        #expect(matched?.matched == true)

        let missing = suite.compare(name: "missing", actual: "<div></div>")
        #expect(missing == nil)
    }

    @Test("Accessibility CI gate fails on errors and supports warning mode")
    func accessibilityCIGateFailureModes() {
        let report = AccessibilityAuditReport(findings: [
            AccessibilityFinding(issue: .missingMainLandmark, severity: .warning, message: "warn"),
            AccessibilityFinding(issue: .inputMissingLabel, severity: .error, message: "error"),
        ])

        #expect(throws: AccessibilityCIGateError.self) {
            try AccessibilityCIGate.validate(report)
        }

        #expect(throws: AccessibilityCIGateError.self) {
            try AccessibilityCIGate.validate(
                AccessibilityAuditReport(findings: [
                    AccessibilityFinding(issue: .missingMainLandmark, severity: .warning, message: "warn"),
                ]),
                options: .init(failOnWarnings: true)
            )
        }
    }
}

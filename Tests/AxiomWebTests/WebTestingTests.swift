import Testing
import Metrics
import MetricsTestKit
@testable import AxiomWebTesting
@testable import AxiomWebUI

private let webTestingMetricsProbe: TestMetrics = {
    let metrics = TestMetrics()
    MetricsSystem.bootstrap(metrics)
    return metrics
}()

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

    @Test("Snapshot and accessibility audit emit metrics")
    func snapshotAndAuditEmitMetrics() throws {
        _ = webTestingMetricsProbe

        _ = SnapshotTesting.compare(expected: "<div><p>A</p></div>", actual: "<div><p>A</p></div>")
        _ = AccessibilityAuditRunner.auditReport(html: "<html lang=\"en\"><body><main></main></body></html>")

        let snapshotCounter = try webTestingMetricsProbe.expectCounter(
            "axiomweb.testing.snapshot.compare.total",
            [("matched", "true")]
        )
        #expect((snapshotCounter.lastValue ?? 0) >= 1)

        let snapshotTimer = try webTestingMetricsProbe.expectTimer("axiomweb.testing.snapshot.compare.duration")
        #expect((snapshotTimer.lastValue ?? 0) >= 0)

        let auditCounter = try webTestingMetricsProbe.expectCounter(
            "axiomweb.testing.accessibility.audit.total",
            [("passed", "true")]
        )
        #expect((auditCounter.lastValue ?? 0) >= 1)

        let auditTimer = try webTestingMetricsProbe.expectTimer("axiomweb.testing.accessibility.audit.duration")
        #expect((auditTimer.lastValue ?? 0) >= 0)
    }

    @Test("Accessibility CI gate emits pass/fail metrics")
    func accessibilityCIGateEmitsMetrics() throws {
        _ = webTestingMetricsProbe

        try AccessibilityCIGate.validate(AccessibilityAuditReport(findings: []))
        #expect(throws: AccessibilityCIGateError.self) {
            try AccessibilityCIGate.validate(
                AccessibilityAuditReport(findings: [
                    AccessibilityFinding(issue: .missingMainLandmark, severity: .warning, message: "warn"),
                ]),
                options: .init(failOnWarnings: true)
            )
        }

        let passCounter = try webTestingMetricsProbe.expectCounter(
            "axiomweb.testing.accessibility.ci.gate.total",
            [("status", "success"), ("fail_on_warnings", "false")]
        )
        #expect((passCounter.lastValue ?? 0) >= 1)

        let failCounter = try webTestingMetricsProbe.expectCounter(
            "axiomweb.testing.accessibility.ci.gate.total",
            [("status", "failure"), ("fail_on_warnings", "true")]
        )
        #expect((failCounter.lastValue ?? 0) >= 1)
    }

    @Test("Performance audit reports budget overruns from HTML and assets")
    func performanceAuditReportsBudgetOverruns() {
        let html = """
<html>
<head>
  <style>.box{color:#333;background:#fff;padding:12px;}</style>
  <script>console.log('boot');console.log('boot2');</script>
</head>
<body>
  <img src="/img/one.png">
  <img src="/img/two.png">
  <main><div class="box">Hello</div></main>
</body>
</html>
"""

        let assets = [
            PerformanceAsset(path: "/public/site.css", bytes: 140, kind: .stylesheet),
            PerformanceAsset(path: "/public/site.js", bytes: 150, kind: .script),
            PerformanceAsset(path: "/public/hero.png", bytes: 260, kind: .image),
            PerformanceAsset(path: "/public/fonts/ui.woff2", bytes: 190, kind: .font),
        ]
        let options = PerformanceAuditOptions(
            budget: .init(
                maxHTMLBytes: 80,
                maxCSSBytes: 90,
                maxJSBytes: 90,
                maxTotalAssetBytes: 300,
                maxImageBytes: 120,
                maxFontBytes: 120,
                maxRequestCount: 1,
                maxDOMNodeCount: 6,
                maxInlineStyleBlockBytes: 12,
                maxInlineScriptBlockBytes: 20
            ),
            warningRatio: 0.9
        )

        let report = PerformanceAuditRunner.auditReport(html: html, assets: assets, options: options)
        #expect(report.findings.contains { $0.issue == .htmlBytesExceeded })
        #expect(report.findings.contains { $0.issue == .cssBytesExceeded })
        #expect(report.findings.contains { $0.issue == .jsBytesExceeded })
        #expect(report.findings.contains { $0.issue == .totalAssetBytesExceeded })
        #expect(report.findings.contains { $0.issue == .imageBytesExceeded })
        #expect(report.findings.contains { $0.issue == .fontBytesExceeded })
        #expect(report.findings.contains { $0.issue == .requestCountExceeded })
        #expect(report.findings.contains { $0.issue == .domNodeCountExceeded })
        #expect(report.findings.contains { $0.issue == .inlineStyleBlockBytesExceeded })
        #expect(report.findings.contains { $0.issue == .inlineScriptBlockBytesExceeded })
    }

    @Test("Performance CI reporter emits markdown and json")
    func performanceCIReporterEmitsMarkdownAndJSON() {
        let report = PerformanceAuditReport(
            snapshot: .init(
                htmlBytes: 120,
                inlineCSSBytes: 20,
                inlineJSBytes: 30,
                totalCSSBytes: 40,
                totalJSBytes: 50,
                totalAssetBytes: 300,
                imageBytes: 200,
                fontBytes: 80,
                requestCount: 5,
                domNodeCount: 35,
                maxInlineStyleBlockBytes: 20,
                maxInlineScriptBlockBytes: 30
            ),
            findings: [
                .init(
                    issue: .htmlBytesExceeded,
                    severity: .error,
                    actual: 120,
                    budget: 100,
                    message: "HTML bytes exceeds budget."
                )
            ]
        )

        let markdown = PerformanceCIReporter.render(report, format: .markdown)
        #expect(markdown.contains("## Performance Audit"))
        #expect(markdown.contains("htmlBytesExceeded"))

        let json = PerformanceCIReporter.render(report, format: .json)
        #expect(json.contains("\"snapshot\""))
        #expect(json.contains("\"htmlBytesExceeded\""))
    }

    @Test("Performance CI gate supports warnings mode")
    func performanceCIGateSupportsWarningsMode() {
        let snapshot = PerformanceSnapshot(
            htmlBytes: 10,
            inlineCSSBytes: 0,
            inlineJSBytes: 0,
            totalCSSBytes: 0,
            totalJSBytes: 0,
            totalAssetBytes: 0,
            imageBytes: 0,
            fontBytes: 0,
            requestCount: 0,
            domNodeCount: 1,
            maxInlineStyleBlockBytes: 0,
            maxInlineScriptBlockBytes: 0
        )

        let warningReport = PerformanceAuditReport(
            snapshot: snapshot,
            findings: [
                PerformanceFinding(
                    issue: .htmlBytesExceeded,
                    severity: .warning,
                    actual: 90,
                    budget: 100,
                    message: "HTML bytes approaches budget."
                )
            ]
        )

        let errorReport = PerformanceAuditReport(
            snapshot: snapshot,
            findings: [
                PerformanceFinding(
                    issue: .jsBytesExceeded,
                    severity: .error,
                    actual: 120,
                    budget: 100,
                    message: "JS bytes exceeds budget."
                )
            ]
        )

        #expect(throws: Never.self) {
            try PerformanceCIGate.validate(warningReport)
        }

        #expect(throws: PerformanceCIGateError.self) {
            try PerformanceCIGate.validate(warningReport, options: .init(failOnWarnings: true))
        }

        #expect(throws: PerformanceCIGateError.self) {
            try PerformanceCIGate.validate(errorReport)
        }
    }

    @Test("Performance audit and gate emit metrics")
    func performanceAuditAndGateEmitMetrics() throws {
        _ = webTestingMetricsProbe

        let report = PerformanceAuditRunner.auditReport(
            html: "<html><body><main><p>Hello</p></main></body></html>",
            assets: [PerformanceAsset(path: "/public/site.css", bytes: 50)]
        )
        try PerformanceCIGate.validate(report)
        #expect(throws: PerformanceCIGateError.self) {
            try PerformanceCIGate.validate(
                PerformanceAuditReport(
                    snapshot: report.snapshot,
                    findings: [
                        PerformanceFinding(
                            issue: .htmlBytesExceeded,
                            severity: .warning,
                            actual: 9,
                            budget: 10,
                            message: "HTML bytes approaches budget."
                        )
                    ]
                ),
                options: .init(failOnWarnings: true)
            )
        }

        let auditCounter = try webTestingMetricsProbe.expectCounter(
            "axiomweb.testing.performance.audit.total",
            [("passed", report.passed ? "true" : "false")]
        )
        #expect((auditCounter.lastValue ?? 0) >= 1)

        let auditTimer = try webTestingMetricsProbe.expectTimer("axiomweb.testing.performance.audit.duration")
        #expect((auditTimer.lastValue ?? 0) >= 0)

        let gateSuccessCounter = try webTestingMetricsProbe.expectCounter(
            "axiomweb.testing.performance.ci.gate.total",
            [("status", "success"), ("fail_on_warnings", "false")]
        )
        #expect((gateSuccessCounter.lastValue ?? 0) >= 1)

        let gateFailureCounter = try webTestingMetricsProbe.expectCounter(
            "axiomweb.testing.performance.ci.gate.total",
            [("status", "failure"), ("fail_on_warnings", "true")]
        )
        #expect((gateFailureCounter.lastValue ?? 0) >= 1)
    }

#if canImport(WebKit)
    @Test("BrowserPage supports click, fill, submit, and attribute flows")
    @MainActor
    func browserPageSupportsInteractionFlow() async throws {
        let page = BrowserPage()
        let html = """
<!doctype html>
<html lang="en">
  <body>
    <main>
      <p id="count">0</p>
      <button id="inc" type="button" onclick="const c=document.getElementById('count');c.textContent=String((parseInt(c.textContent,10)||0)+1)">Inc</button>
      <form id="profile" onsubmit="event.preventDefault();document.getElementById('status').textContent='submitted:'+document.getElementById('name').value;">
        <input id="name" name="name" value="">
        <button id="save" type="submit">Save</button>
      </form>
      <p id="status"></p>
    </main>
  </body>
</html>
"""

        try await page.setHTML(html)
        try await page.click("#inc")
        #expect(try await page.textContent(of: "#count") == "1")

        try await page.fill("#name", with: "Axiom")
        #expect(try await page.attribute(of: "#name", name: "name") == "name")

        try await page.submit("#profile")
        try await page.waitForText("submitted:Axiom", in: "#status")
        #expect(try await page.textContent(of: "#status") == "submitted:Axiom")
    }

    @Test("BrowserPage waits for async DOM updates and emits normalized snapshots")
    @MainActor
    func browserPageWaitAndSnapshotFlow() async throws {
        let page = BrowserPage()
        let html = """
<!doctype html>
<html lang="en">
  <body>
    <main>
      <p id="async">pending</p>
      <script>
        setTimeout(function(){
          document.getElementById('async').textContent = 'ready';
        }, 20);
      </script>
    </main>
  </body>
</html>
"""

        try await page.setHTML(html)
        try await page.waitForText("ready", in: "#async", timeout: .seconds(2), pollEvery: .milliseconds(20))
        let snapshot = try await page.normalizedSnapshot()
        #expect(snapshot.contains("id=\"async\">ready</p>"))
    }
#endif
}

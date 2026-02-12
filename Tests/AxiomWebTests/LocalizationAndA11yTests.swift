import Testing
@testable import AxiomWebI18n
@testable import AxiomWebTesting

@Suite("Localization and Accessibility")
struct LocalizationAndA11yTests {
    @Test("Maps localized paths with default locale fallback")
    func localizedPathMapping() {
        #expect(LocaleRouting.localizedPath("/", locale: .en, defaultLocale: .en) == "/")
        #expect(LocaleRouting.localizedPath("/contact", locale: .en, defaultLocale: .en) == "/contact")
        #expect(LocaleRouting.localizedPath("/contact", locale: "fr", defaultLocale: .en) == "/fr/contact")
    }

    @Test("Accessibility audit flags common violations")
    func accessibilityAuditFindsIssues() {
        let issues = AccessibilityAuditRunner.audit(html: "<html><body><img src=\"x\"><input name=\"email\"></body></html>")
        #expect(issues.contains(.imageMissingAlt))
        #expect(issues.contains(.inputMissingLabel))
        #expect(issues.contains(.missingMainLandmark))
    }
}

# Build Audits

Run accessibility and performance audits as part of static site generation.

## Overview

`StaticSiteBuilder` can audit each generated page and optionally fail the build when gates are violated.

- Accessibility: `AccessibilityAuditRunner` + `AccessibilityCIGate`
- Performance: `PerformanceAuditRunner` + `PerformanceCIGate`

Audits emit per-page reports and can write JSON or Markdown output files in the build directory.

## Server Build Configuration

```swift
import Foundation
import AxiomWebServer
import AxiomWebTesting

let config = ServerBuildConfiguration(
    outputDirectory: URL(filePath: ".output"),
    performanceAudit: .init(
        enabled: true,
        enforceGate: true,
        options: .init(
            budget: .init(
                maxHTMLBytes: 128_000,
                maxCSSBytes: 96_000,
                maxJSBytes: 160_000,
                maxTotalAssetBytes: 900_000
            )
        ),
        gateOptions: .init(failOnWarnings: false),
        reportFormat: .json
    ),
    accessibilityAudit: .init(
        enabled: true,
        enforceGate: true,
        options: .init(
            checkImageAlt: true,
            checkInputLabels: true,
            checkMainLandmark: true,
            checkButtonNames: true,
            checkHTMLLang: true,
            checkTabIndex: true,
            checkMotion: true,
            checkRoles: true,
            checkFocusStyles: true,
            checkContrast: true
        ),
        gateOptions: .init(failOnWarnings: false),
        reportFormat: .json
    )
)

let report = try StaticSiteBuilder(configuration: config).build()
print(report.performanceReportPath ?? "no performance report")
print(report.accessibilityReportPath ?? "no accessibility report")
```

## CLI Usage

```bash
axiomweb-build \
  --output .output \
  --performance-audit \
  --performance-report-format json \
  --performance-max-html-bytes 128000 \
  --performance-max-css-bytes 96000 \
  --performance-max-js-bytes 160000 \
  --performance-max-total-asset-bytes 900000 \
  --accessibility-audit \
  --accessibility-report-format json
```

Use report-only mode when you want reports without failing the build:

```bash
axiomweb-build --performance-report-only --accessibility-report-only
```

## Report Artifacts

By default, reports are written to:

- `.output/performance-audit.json`
- `.output/accessibility-audit.json`

Override names with:

- `--performance-report-file`
- `--accessibility-report-file`


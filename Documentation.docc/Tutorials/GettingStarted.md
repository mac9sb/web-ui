# Getting Started

## Project Layout

Use convention-first route discovery and default asset locations:

```text
Routes/
  pages/
    index.swift
    contact.swift
    path/goodbye.swift
  api/
    hello.swift
Assets/
  images/
  fonts/
```

- `Routes/pages/index.swift` -> `/`
- `Routes/pages/contact.swift` -> `/contact`
- `Routes/pages/path/goodbye.swift` -> `/path/goodbye`
- `Routes/api/hello.swift` -> `/api/hello`
- Static assets are read from `Assets/` and copied to `.output/public/`

## Minimal Page

```swift
import AxiomWebUI

struct Home: Document {
    var metadata: Metadata { Metadata(title: "Home") }
    var path: String { "/" } // optional when inferred from file path

    var body: some Markup {
        Main {
            Heading(.h1, "Hello")
            Paragraph("AxiomWeb is rendering this page from typed APIs.")
        }
    }
}
```

## Build Commands

Static site build:

```bash
swift run axiomweb-build --output .output --base-url https://example.com
```

Server-side app build mode:

```bash
swift run axiomweb-build --build-mode serverSide
```

Auto build mode (default):

- resolves to `serverSide` when any API route exists
- resolves to `staticSite` when no API route exists

## Locale-Aware Build

```bash
swift run axiomweb-build \
  --default-locale en \
  --locales en fr de \
  --base-url https://example.com
```

## CI-Friendly Audits

```bash
swift run axiomweb-build \
  --performance-audit \
  --accessibility-audit \
  --performance-report-format json \
  --accessibility-report-format json
```

See also:

- <doc:RoutingGuide>
- <doc:APIContractsGuide>
- <doc:BuildModesGuide>
- <doc:LocalizationGuide>

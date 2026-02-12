# Localization Guide

Build locale-aware pages, metadata, and URLs from typed APIs.

## Overview

AxiomWeb localization uses typed values across rendering and static builds:

- `LocaleCode` for language identifiers.
- `LocalizedStringKey`, `LocalizedString`, and `LocalizedStringTable` for content.
- `LocaleRouting` for locale-aware path and URL generation.
- Static build locale fan-out through `ServerBuildConfiguration.defaultLocale` and `ServerBuildConfiguration.locales`.

## Typed Localized Content

```swift
import AxiomWebI18n
import AxiomWebUI

var strings = LocalizedStringTable([
    "home.greeting": .init([
        .en: "Welcome",
        "fr": "Bonjour",
    ])
])

struct Home: Document {
    var metadata: Metadata { Metadata(title: "Home") }
    var path: String { "/" }

    var body: some Markup {
        Main {
            Paragraph {
                LocalizedText("home.greeting", from: strings)
            }
        }
    }
}
```

`LocalizedText` resolves against the active render locale and falls back to the configured fallback locale (`.en` by default).

## Locale-Aware Routing and URLs

```swift
import AxiomWebI18n

let pathEN = LocaleRouting.localizedPath("/contact", locale: .en, defaultLocale: .en)   // /contact
let pathFR = LocaleRouting.localizedPath("/contact", locale: "fr", defaultLocale: .en) // /fr/contact

let urlFR = LocaleRouting.localizedURL(
    baseURL: "https://example.com",
    path: "/contact",
    locale: "fr",
    defaultLocale: .en
) // https://example.com/fr/contact
```

## Static Generation Per Locale

```swift
import Foundation
import AxiomWebI18n
import AxiomWebServer

let config = ServerBuildConfiguration(
    outputDirectory: URL(filePath: ".output"),
    defaultLocale: .en,
    locales: ["fr", "de"],
    baseURL: "https://example.com"
)

let report = try StaticSiteBuilder(configuration: config).build()
print(report.localeCount) // includes default locale
```

Generated output uses:

- default locale without prefix (`/contact`)
- non-default locales with prefix (`/fr/contact`, `/de/contact`)

## Metadata, `hreflang`, and Localized Structured Data

When `baseURL` is provided, static builds generate locale-aware canonical and alternate links:

- `<link rel="canonical" ...>`
- `<link rel="alternate" hreflang="...">`

Sitemaps also include localized URLs for every route/locale combination.

Structured data supports localized fields via `LocalizedString` and is rendered per locale:

```swift
Metadata(
    structuredData: [
        .webPage(
            .init(
                id: "urn:site:home",
                name: .init([.en: "Home", "fr": "Accueil"]),
                url: "/"
            )
        )
    ]
)
```

## CLI Locale Controls

```bash
axiomweb-build \
  --default-locale en \
  --locales en fr de \
  --base-url https://example.com
```


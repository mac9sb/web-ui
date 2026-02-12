# ADR-0003: Localization and Locale Routing

## Status

Accepted

## Context

AxiomWeb needs first-class localization with:

- typed localized keys/values
- locale-aware route and URL generation
- static generation per locale
- SEO alignment (`hreflang`, localized sitemap, canonical links)
- locale-aware structured data output

## Decision

1. Localization primitives remain typed in `AxiomWebI18n`:
   - `LocaleCode`
   - `LocalizedStringKey`
   - `LocalizedString`
   - `LocalizedStringTable`
2. Route and URL helpers are centralized in `LocaleRouting`:
   - `localizedPath`
   - `localizedURL`
3. Static build locale fan-out is configured with:
   - `ServerBuildConfiguration.defaultLocale`
   - `ServerBuildConfiguration.locales`
4. `RenderEngine` and metadata pipelines emit locale-specific:
   - `<html lang=...>`
   - canonical links
   - `hreflang` alternates
   - localized JSON-LD values

## Consequences

- Locale behavior stays deterministic and testable from one API surface.
- Server and render layers share consistent route/url localization behavior.
- SEO output stays aligned with generated localized routes.

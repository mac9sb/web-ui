# Getting Started

1. Define routes in `Routes/pages` and `Routes/api`.
2. Build with `AxiomWebCLI` or `StaticSiteBuilder`.
3. Place static assets in `Assets/`.
4. Output is generated into `.output/` with public assets under `.output/public/`.

## Quick Build

```bash
swift run axiomweb-build --output .output --base-url https://example.com
```

## Multi-Locale Build

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

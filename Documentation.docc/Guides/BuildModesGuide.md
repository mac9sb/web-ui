# Build Modes Guide

AxiomWeb supports three build modes through `ServerBuildConfiguration.buildMode`.

## Modes

- `.auto` (default): resolves by discovery.
- `.staticSite`: always emits static HTML/assets output.
- `.serverSide`: resolves routes and contracts for server runtime; static HTML files are not emitted.

Auto mode resolution:

- if discovered API routes are empty -> `.staticSite`
- if discovered API routes exist -> `.serverSide`

## Configuration

```swift
import Foundation
import AxiomWebServer

let config = ServerBuildConfiguration(
    outputDirectory: URL(filePath: ".output"),
    buildMode: .auto
)
```

## CLI

```bash
axiomweb-build --build-mode auto
axiomweb-build --build-mode staticSite
axiomweb-build --build-mode serverSide
```

## Full-Stack vs Static

Use `.serverSide` when you are shipping a Swift server binary with API routes and server integrations.

Use `.staticSite` when you only need generated static output for deployment to static hosting/CDN.

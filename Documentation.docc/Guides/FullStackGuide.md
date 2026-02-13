# Full-Stack Guide

Use AxiomWeb in static or server-side mode from one codebase.

## Build Modes

- `.auto`: defaults to static output unless API or websocket routes are discovered.
- `.staticSite`: always emits HTML/assets output.
- `.serverSide`: resolves routes/contracts for server runtime only.

## CLI

```bash
axiomweb-build --build-mode auto
axiomweb-build --build-mode staticSite
axiomweb-build --build-mode serverSide
```

## Strict Route Contracts

Enable strict contract checks to fail builds when discovered route files are missing typed registrations.

```bash
axiomweb-build --strict-route-contracts
```

Equivalent Swift configuration:

```swift
import Foundation
import AxiomWebServer

let config = ServerBuildConfiguration(
    outputDirectory: URL(filePath: ".output"),
    buildMode: .auto,
    strictRouteContracts: true
)
```

## Runtime

For long-running server binaries, instantiate `AxiomWebServerRuntime` with typed API/websocket route overrides/contracts and run in `serverSide` mode.

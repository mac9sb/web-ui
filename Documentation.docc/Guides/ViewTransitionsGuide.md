# View Transitions Guide

Use typed APIs to enable document-level and application-level view transitions.

## Overview

AxiomWeb supports view transitions through:

- `ViewTransitionConfiguration`
- `ViewTransitionProviding`
- `RenderEngine.render(..., viewTransition:)`
- `ServerBuildConfiguration.viewTransition`
- `viewTransitionName(...)` style modifiers for named transition targets

No raw CSS/JS strings are required.

## Document-Level Declaration

```swift
import AxiomWebUI
import AxiomWebStyle

struct ProfilePage: Document, ViewTransitionProviding {
    var metadata: Metadata { Metadata(title: "Profile") }
    var path: String { "/profile" }

    var viewTransition: ViewTransitionConfiguration {
        .init(
            navigation: .auto,
            runtimeNavigation: true,
            durationSeconds: 0.45,
            timing: .easeInOut
        )
    }

    var body: some Markup {
        Stack {
            Heading(.h1, "Profile")
        }
        .viewTransitionName("profile")
    }
}
```

## Application-Level Declaration

Apply a shared configuration at website/build level, with optional page overrides.

```swift
import Foundation
import AxiomWebServer
import AxiomWebUI

let config = ServerBuildConfiguration(
    outputDirectory: URL(filePath: ".output"),
    viewTransition: .init(
        navigation: .auto,
        runtimeNavigation: true,
        durationSeconds: 0.35
    )
)
```

If a page also conforms to `ViewTransitionProviding`, the page configuration takes precedence.

## Render-Time Override

```swift
let rendered = try RenderEngine.render(
    document: page,
    locale: .en,
    viewTransition: .init(
        navigation: .none,
        runtimeNavigation: false,
        applyRootAnimation: false
    )
)
```

## Runtime Navigation

When `runtimeNavigation` is enabled, typed runtime navigation actions use `document.startViewTransition(...)` when available, and fall back automatically when unsupported.

## Accessibility

`respectReducedMotion` defaults to `true` and emits reduced-motion-safe transition CSS for root animations.


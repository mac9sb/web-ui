# Routing Guide

AxiomWeb uses convention-first route discovery with optional typed overrides.

## Route Conventions

### Pages

- `Routes/pages/index.swift` -> `/`
- `Routes/pages/contact.swift` -> `/contact`
- `Routes/pages/path/goodbye.swift` -> `/path/goodbye`

### APIs

- `Routes/api/hello.swift` -> `/api/hello`
- `Routes/api/path/goodbye.swift` -> `/api/path/goodbye`

### WebSockets

- `Routes/ws/echo.swift` -> `/ws/echo`
- `Routes/ws/path/updates.swift` -> `/ws/path/updates`

### Dynamic Segments

- `Routes/pages/blog/[slug].swift` -> `/blog/:slug`
- `Routes/pages/docs/[...path].swift` -> `/docs/*path`

## Page Path Overrides

Path is inferred from file location by default, but a page can override with `var path`.

```swift
import AxiomWebUI

struct SupportPage: Document {
    var metadata: Metadata { Metadata(title: "Support") }
    var path: String { "/help" }

    var body: some Markup {
        Main { Text("Support") }
    }
}
```

## API Contracts with Multiple Methods

A single API path can register multiple HTTP methods through typed contracts.

```swift
import HTTPTypes
import AxiomWebServer

struct HelloGet: APIRouteContract {
    static var method: HTTPRequest.Method { .get }
    static var path: String { "/api/hello" }

    func handle(request: EmptyAPIRequest, context: APIRequestContext) async throws -> APIResponse<String> {
        APIResponse(body: "hello")
    }
}

struct HelloPost: APIRouteContract {
    static var method: HTTPRequest.Method { .post }
    static var path: String { "/api/hello" }

    func handle(request: EmptyAPIRequest, context: APIRequestContext) async throws -> APIResponse<Bool> {
        APIResponse(body: true)
    }
}
```

## Build Mode Resolution

`ServerBuildConfiguration.buildMode` supports:

- `.auto` (default): resolves to `.serverSide` if API or websocket routes exist, otherwise `.staticSite`
- `.staticSite`: always emit static output
- `.serverSide`: skip static artifact emission

This allows static-first behavior by discovery while preserving explicit overrides.

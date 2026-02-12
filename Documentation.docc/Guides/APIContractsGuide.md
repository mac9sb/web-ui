# API Contracts Guide

AxiomWeb supports typed API handlers with one or multiple methods on a single route path.

## Route File Convention

- `Routes/api/hello.swift` maps to `/api/hello`
- `Routes/api/path/goodbye.swift` maps to `/api/path/goodbye`

Path is inferred from file location by default.

## Contract Type

Use `APIRouteContract` for a single method route:

```swift
import HTTPTypes
import AxiomWebServer

struct HelloRoute: APIRouteContract {
    static var method: HTTPRequest.Method { .get }
    static var path: String { "/api/hello" }

    func handle(
        request: EmptyAPIRequest,
        context: APIRequestContext
    ) async throws -> APIResponse<String> {
        APIResponse(body: "hello")
    }
}
```

## Multiple Methods on the Same Path

Use `RouteOverrides.api(_:build:)` with `APIMethodRouteBuilder`:

```swift
import HTTPTypes
import AxiomWebServer

var overrides = RouteOverrides()
overrides.api("/api/contact") { route in
    route
        .get { (_: APIRequestContext) async throws -> APIResponse<[String]> in
            APIResponse(body: ["open", "closed"])
        }
        .post { (request: ContactRequest, _: APIRequestContext) async throws -> APIResponse<ContactResult> in
            APIResponse(statusCode: 201, body: .init(ok: true))
        }
}
```

## Build Integration

Pass contracts/overrides through `ServerBuildConfiguration`:

```swift
import Foundation
import AxiomWebServer

let config = ServerBuildConfiguration(
    outputDirectory: URL(filePath: ".output"),
    overrides: overrides
)
```

The same typed route contracts are used by static-build route resolution and server runtime routing.

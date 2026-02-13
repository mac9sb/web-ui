# Data and Forms Guide

AxiomWeb provides typed fetch/cache policies and typed form validation primitives.

## Typed Data Fetch Policies

Use `FetchPolicy` to model SSR/SSG/ISR cache behavior:

```swift
import Foundation
import AxiomWebRuntime

let request = FetchRequest(
    url: URL(string: "https://example.com/api/posts")!,
    policy: .isr60s
)
```

Built-in policy presets:

- `FetchPolicy.ssrNoStore`
- `FetchPolicy.ssgImmutable`
- `FetchPolicy.isr60s`

## Cached Fetch Execution

```swift
import AxiomWebRuntime

let executor = FetchExecutor(fetcher: myFetcher)
let response = try await executor.perform(request)
```

`FetchExecutor` supports fresh/stale cache semantics via `InMemoryFetchCache`:

- `noStore`
- `immutable`
- `revalidateAfter(seconds:)`
- `staleWhileRevalidate(seconds:)`

## Typed Form Schema Validation

```swift
import AxiomWebUI

let schema = FormSchema([
    .init(field: .init(name: "email", type: .email, required: true)),
    .init(field: .init(name: "age", type: .number), customValidator: { value in
        (Int(value) ?? 0) < 18 ? "Must be at least 18" : nil
    }),
])

let errors = schema.validate([
    "email": "dev@example.com",
    "age": "21",
])
```

Validation results are typed as `FormValidationError` and can be mapped directly into page/API responses.

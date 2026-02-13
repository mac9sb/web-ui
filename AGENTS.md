# AxiomWeb Agent Guidelines

## Design Standards

1. Follow Swift API design rigor.
- Strictly follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) so APIs stay clear, consistent, and declarative.

2. Prefer typed first-class APIs when possible.
- If a low-level fallback is used and a typed API would make sense for baseline HTML/CSS/JS authoring, add the typed API in the same change when practical.

## Dependency Rules

1. Check trusted package sources first before custom implementation:
- [Apple Collection](https://swiftpackageindex.com/apple/collection.json)
- [Swift.org Collection](https://swiftpackageindex.com/swiftlang/collection.json)
- [SSWG Collection](https://swiftpackageindex.com/sswg/collection.json)
- [Swift Server Community](https://swiftpackageindex.com/swift-server-community/collection.json)

2. Do not add dependencies outside these sources silently.
- Ask permission first and explain why the dependency is necessary and the tradeoffs.

## DSL Authoring Rules

1. Prefer typed DSL elements over raw tag strings.
- Use typed elements like `Section`, `Dialog`, `Output`, `NoScript`, `Label`, `Input`, `Span` wrappers when available.
- Do not use `Node("tag", ...)` for tags that already have a typed DSL member.

2. Prefer semantic layout modifiers over low-level CSS keywords.
- Use `.flex(...)` and `.grid(...)` style APIs for layout intent.
- Do not use `.display(.keyword("flex"))` or `.display(.keyword("grid"))` where semantic helpers exist.
- `rowGap` and `columnGap` helpers are disallowed; use `gap` via semantic layout helpers.

3. Use low-level escape hatches only when there is no typed API yet.
- Allowed fallbacks: `Node("...")`, `.css(...)`, raw CSS values.
- If fallback is used, keep it minimal and scoped, and add a typed API when it fits the DSL.

4. Keep the public authoring model SwiftUI-like and declarative.
- Chained modifiers, `.on {}` variants/interactions, typed metadata, typed runtime actions.
- Avoid stringly-typed HTML/CSS/JS patterns in framework and component code unless strictly necessary.

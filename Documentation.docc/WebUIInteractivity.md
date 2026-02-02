# WebUIInteractivity — Proposal

## Overview
`WebUIInteractivity` is a proposed module that adds a **declarative, typed state and interactivity engine** to WebUI. It mirrors the developer experience of `WebUIBrowserTesting`’s script builder, but targets **production usage** with CSP‑friendly **data‑attribute bindings** and a **small delegated JavaScript runtime**.

This document proposes the API, runtime, and module structure to support:
- Typed state in Swift
- Global, page, and component scopes
- Declarative bindings for text, attributes, styles, and properties
- Declarative event actions (click/input/submit/etc.)
- A tiny runtime injected once per page

---

## Goals

### Functional
- **Declarative API** in Swift
- **Typed state keys** for safety
- **Hierarchical state** (App → Page → Component)
- **CRUD for state** (create, read, update, delete)
- **Bind state to DOM** (content, attributes, styles, properties)
- **Declarative actions** on events
- **Small JS runtime** that handles binding and events

### Non‑functional
- **CSP compatible** (no inline JS required)
- **Scalable** for large apps (event delegation + minimal listeners)
- **Composable** (state scoped to components)
- **Framework‑agnostic** (no dependency on a client framework)

---

## Module Structure

```
WebUIInteractivity
├── Core
│   ├── StateKey.swift
│   ├── StateScope.swift
│   ├── StateScript.swift
│   ├── Binding.swift
│   ├── Action.swift
│   └── Event.swift
├── Runtime
│   ├── InteractivityRuntime.js
│   └── RuntimeInjector.swift
└── Extensions
    └── Markup+Interactivity.swift
```

**Why a separate module?**  
Keeps core `WebUI` small and stable, while allowing interactivity features to evolve independently (better for long‑term scale).

---

## API Proposal (Swift)

### 0) Ergonomics Enhancements (KeyPath‑first + Auto‑ID)

To reduce boilerplate and improve safety, the primary API should allow **KeyPath‑based state access** and **implicit element IDs**.

**KeyPath State Access**
- Define state in a schema and bind using `KeyPath`s (no manual `StateKey("count")`).
- Keeps state typed and discoverable at compile time.

**Implicit / Auto IDs**
- Markup modifiers should auto‑assign a stable `id` when missing.
- Users can still provide explicit IDs for cross‑component wiring.

```swift
public protocol StateSchema {}

public struct StateStore<Schema: StateSchema> {
    // resolves KeyPaths to StateKeys internally
}

struct HomeState: StateSchema {
    var count = 0
    var username = "Mac"
}

Text("0")
    .bindText(\HomeState.count)

Button("Increment")
    .on(.click, .increment(\HomeState.count, by: 1)) // auto-id
```

### 1) Typed Keys

```swift
public struct StateKey<Value> {
    public let name: String
    public init(_ name: String) { self.name = name }
}

public struct AnyStateKey {
    public let name: String
    public init<T>(_ key: StateKey<T>) { self.name = key.name }
}
```

---

### 2) State Scopes

```swift
public enum StateScope {
    case app
    case page(id: String)
    case component(id: String)

    var scopeId: String { ... } // used for DOM scoping
}
```

Hierarchy resolution at runtime:
```
component store → page store → app store
```

---

### 3) Script Builder (Result Builder)

This uses a result builder pattern (mirroring `WebUIBrowserTesting`’s script builder) to keep scripts declarative, composable, and conditional.

```swift
public struct StateScript {
    public let statements: [StateStatement]
    public init(@StateScriptBuilder _ build: () -> [StateStatement]) { ... }
}

@resultBuilder
public enum StateScriptBuilder {
    public static func buildBlock(_ components: [StateStatement]...) -> [StateStatement] {
        components.flatMap { $0 }
    }
    public static func buildExpression(_ expression: StateStatement) -> [StateStatement] {
        [expression]
    }
    public static func buildOptional(_ component: [StateStatement]?) -> [StateStatement] {
        component ?? []
    }
    public static func buildEither(first component: [StateStatement]) -> [StateStatement] {
        component
    }
    public static func buildEither(second component: [StateStatement]) -> [StateStatement] {
        component
    }
    public static func buildArray(_ components: [[StateStatement]]) -> [StateStatement] {
        components.flatMap { $0 }
    }
}

public enum StateStatement {
    case define(scope: StateScope, key: AnyStateKey, initialJSON: String)
    case bind(Binding)
    case on(EventBinding)
    case custom(String)
}
```

---

### 4) Bindings

```swift
public enum Binding {
    case text(id: String, key: AnyStateKey)
    case html(id: String, key: AnyStateKey)
    case attr(id: String, name: String, key: AnyStateKey)
    case prop(id: String, name: String, key: AnyStateKey)
    case style(id: String, name: String, key: AnyStateKey)
    case `class`(id: String, name: String, when: StatePredicate)
}
```

**Typed Value Mapping (Value Mapper)**  
Replace stringly‑typed ternaries with a typed mapping closure that serializes to a compact JSON map for the runtime.

```swift
.bindStyle(id: "box", .display, from: \HomeState.isVisible) { value in
    value ? "block" : "none"
}
```

---


### 5) Actions

```swift
public enum Action {
    case set(AnyStateKey, StateValue)
    case increment(AnyStateKey, by: Int)
    case toggle(AnyStateKey)
    case delete(AnyStateKey)
    case sequence([Action])
    case custom(String) // escape hatch
}
```

---

### 6) Events

```swift
public enum EventType: String {
    case click, input, change, submit, focus, blur, keyDown, keyUp
}

public struct EventBinding {
    public let event: EventType
    public let targetId: String
    public let action: Action
}
```

---

## Runtime Model (JS)

### Store
A simple store per scope:
- `get(key)`
- `set(key, value)`
- `delete(key)`
- change listeners notify bindings

### Bindings
Bindings are encoded as `data-wui-*` attributes:
- `data-wui-bind-text="count"`
- `data-wui-bind-attr="title:username"`
- `data-wui-bind-style="display:isVisible?block:none"`

### Events
Runtime uses **event delegation**:
- One listener per event type
- Finds closest `[data-wui-action]`
- Executes the action by parsing a **compact action DSL** (e.g., `inc:count:1`)

### Dynamic Content
Use a **MutationObserver** to discover and register bindings for elements inserted after initial render.

---


## Markup Integration

Add lightweight modifiers that work on any `Markup` (with implicit IDs when missing):

```swift
Text("0")
    .bindText(\HomeState.count)

Button("Increment")
    .on(.click, .increment(\HomeState.count, by: 1))
```

These modifiers emit `data-wui-*` attributes, no inline JS.

---

## Example Usage

```swift
struct HomeState: StateSchema {
    var count = 0
    var username = "Mac"
}

let enableDebug = true

let script = StateScript {
    Define(.page(id: "home"), \HomeState.count, initial: 0)
    Bind.text(id: "count-label", \HomeState.count)
    On(.click, id: "inc", action: .increment(\HomeState.count, by: 1))

    if enableDebug {
        On(.click, id: "reset", action: .set(\HomeState.count, .int(0)))
    }
}
```

---

## Runtime Injection

A single helper injects the runtime and bindings into the document head:

```swift
Head {
    WebUIInteractivity.runtime()
    WebUIInteractivity.bootstrap(script)
}
```

---

## Security & CSP

- **No inline JS required**
- Runtime can be served as external file
- `data-*` attributes only
- Optional escape hatch for inline JS, but discouraged

---

## Future Extensions (Not MVP)

- Effects (async actions)
- Derived state / computed selectors
- Built‑in transitions/animations
- Server‑driven hydration

---

## MVP Scope Summary

✅ Typed state keys  
✅ Hierarchical scopes  
✅ CRUD actions  
✅ Bindings for text/attr/style/prop/class  
✅ Event delegation  
✅ Runtime injection  
✅ CSP‑safe defaults

---

## Conclusion

This design brings a **declarative, production‑grade interactivity layer** to WebUI that mirrors the elegance of `WebUIBrowserTesting` while remaining secure and scalable for large apps. The module separation allows clean evolution without impacting the core rendering system.

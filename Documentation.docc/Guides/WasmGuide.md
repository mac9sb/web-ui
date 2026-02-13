# WASM Guide

AxiomWeb supports typed WebAssembly integration without raw JavaScript authoring.

## `WasmCanvas`

Use `WasmCanvas` for wasm-driven rendering surfaces:

```swift
import AxiomWebRuntime
import AxiomWebUIComponents

WasmCanvas(
    id: "scene",
    modulePath: "/public/wasm/scene.mjs",
    mountExport: "mount",
    initialPayload: .object([
        "seed": .int(42),
        "theme": .string("light"),
    ])
)
```

## Typed Invocation

From declarative runtime interactions:

```swift
.on {
    $0.click {
        $0.invokeWasm(on: "scene", export: "refresh", payload: .object([
            "full": .bool(true),
        ]))
    }
}
```

## Fallback Behavior

`WasmCanvas` emits fallback content and `noscript` output for non-wasm/no-script environments.

## Playground Note

Planned ecosystem sample:

- publish an AxiomWeb wasm playground example via GitHub Pages
- include typed component/runtime/wasm interop examples as canonical reference

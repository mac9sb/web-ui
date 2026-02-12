# Runtime Interactivity Guide

AxiomWeb interactivity is declared in Swift and emitted as generated JavaScript.

## `@State` + `.on {}` on Elements

Use SwiftUI-like `@State` and event scopes inside `.on {}`.

```swift
import AxiomWebRuntime
import AxiomWebUI

struct CounterCard: Element {
    @State("counter") var count = 0

    var body: some Markup {
        Stack {
            Button("+1")
                .on {
                    $0.click {
                        $0.increment($count)
                    }
                }

            Button("-1")
                .on {
                    $0.click {
                        $0.decrement($count)
                    }
                }
        }
    }
}
```

Supported DOM events in `.on {}`:

- `click`
- `input`
- `change`
- `submit`

## Timers and Programmatic Runtime

For timed actions (timeout/interval), conform documents to `RuntimeProgramProviding`.

```swift
import AxiomWebRuntime
import AxiomWebUI

struct TimedPage: Document, RuntimeProgramProviding {
    @State("tick") var tick = 0

    var metadata: Metadata { Metadata(title: "Timed") }
    var path: String { "/timed" }

    var runtimeProgram: RuntimeProgram {
        RuntimeProgram {
            Runtime.state($tick)
            Runtime.every(seconds: 1, perform: Runtime.increment($tick))
        }
    }

    var body: some Markup {
        Main {
            Paragraph("Timer-driven state is running.")
        }
    }
}
```

## WASM Invocation

Inside interaction scopes, call into a mounted wasm surface with typed payloads:

```swift
.on {
    $0.click {
        $0.invokeWasm(on: "demo-canvas", export: "refresh", payload: .object([
            "force": .bool(true)
        ]))
    }
}
```

No raw JavaScript string authoring is required for these interactions.

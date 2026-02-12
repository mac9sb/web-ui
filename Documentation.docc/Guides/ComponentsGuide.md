# Components Guide

`AxiomWebUIComponents` is a native-first component layer on top of `AxiomWebUI`.

## Design Principles

- Components are built from typed DSL markup and style modifiers.
- Prefer platform-native HTML features first (`details`, `dialog`, `popover`, semantic form controls).
- Use generated JavaScript only when native behavior cannot cover the interaction.
- Components inherit `AxiomWebStyle` modifiers and optional `ComponentTheme` overrides.

## Example

```swift
import AxiomWebUI
import AxiomWebUIComponents

struct ComponentsPage: Document {
    var metadata: Metadata { Metadata(title: "Components") }
    var path: String { "/components" }

    var body: some Markup {
        Main {
            Card {
                Badge("Beta", tone: .accent)
                Alert(title: "Heads up", message: "Native-first primitives are enabled.")
            }

            Accordion {
                AccordionItem("What is this?") {
                    Paragraph("Accordion uses native <details>/<summary>.")
                }
            }

            Popover(id: "help", triggerLabel: "Open Help") {
                Paragraph("Popover uses the native popover attribute.")
            }

            ModalDialog(id: "confirm", triggerLabel: "Confirm") {
                Paragraph("Dialog uses native <dialog> semantics.")
            }
        }
    }
}
```

## Theming

Pass a custom `ComponentTheme` per component or set `ComponentThemeStore.current` for app-wide defaults.

Theme knobs include:

- color tokens (surface/foreground/accent/destructive/muted/border)
- corner radius
- spacing scale multiplier

## Additional Native-First Components

- `Breadcrumbs`
- `Pagination`
- `ProgressBar`
- `Separator`
- `Avatar`
- `Skeleton`
- `CheckboxField`
- `SwitchField`
- `SelectField`
- `DataTable`

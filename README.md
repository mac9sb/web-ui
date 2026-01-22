# WebUI

A Swift library for building type-safe, modern websites with support for both static site generation (SSG) and server-side rendering (SSR).

## Overview

WebUI provides a declarative, type-safe API for building websites in Swift:

- **Type-Safe HTML Generation**: Build HTML using Swift's type system
- **Static Site Generation**: Generate complete websites at build time
- **Server-Side Rendering**: Render pages dynamically on the server
- **Component-Based**: Reusable components for common UI patterns
- **Markdown & Typst Support**: Write content in Markdown or Typst

## Getting Started

### Installation

Add WebUI to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mac9sb/web-ui", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "WebUI", package: "web-ui"),
        .product(name: "WebUITypst", package: "web-ui"), // Optional
        .product(name: "WebUIMarkdown", package: "web-ui") // Optional
    ]
)
```

### Static Site Generation

Create a website:

```swift
import WebUI

struct MyWebsite: Website {
    var metadata: Metadata {
        Metadata(
            title: "My Website",
            description: "Built with WebUI"
        )
    }

    var routes: [any Document] {
        [
            HomePage(),
            AboutPage()
        ]
    }
}
```

Define pages:

```swift
struct HomePage: Document {
    var metadata: Metadata {
        Metadata(title: "Home")
    }

    var body: some Markup {
        HTML {
            Head {
                Title("My Website")
                Meta(charset: .utf8)
            }
            Body {
                Header { /* Navigation */ }
                Main { /* Page content */ }
                Footer { /* Footer content */ }
            }
        }
    }
}
```

Build the site:

```swift
try MyWebsite().build(to: URL(filePath: ".output"))
```

### Server-Side Rendering

Use with Hummingbird:

```swift
import Hummingbird
import WebUI

func blogRoutes(_ router: Router) {
    router.get("/blog/:slug") { request, context -> HTMLResponse in
        let slug = request.parameters.get("slug", as: String.self)!
        let page = BlogPostPage(slug: slug)
        return HTMLResponse(page)
    }
}
```

## Architecture

WebUI consists of several modules:

- **WebUI**: Core library for HTML generation and website building
- **WebUITypst**: Typst content rendering support
- **WebUIMarkdown**: Markdown content rendering support

### Key Components

- **Website Protocol**: Define complete websites
- **Document Protocol**: Define individual pages
- **Element Protocol**: Build HTML elements type-safely
- **Markup**: Compose page content
- **SSRBuilder**: Generate CSS for server-side rendering

## Features

### Type-Safe HTML

Build HTML using Swift's type system:

```swift
Div {
    Heading(.h1, "Welcome")
    Text("Hello, world!")
        .font(size: .lg)
        .textAlign(.center)
}
```

### Responsive Design

Built-in responsive utilities:

```swift
VStack {
    Text("Content")
        .on {
            $0.md { $0.font(size: .xl) }
            $0.sm { $0.font(size: .lg) }
        }
}
```

### CSS Generation

Automatic CSS generation for SSR mode:

```swift
try SSRBuilder(
    config: CSSOutputConfig(
        ssrOutputDir: "Public/",
        mode: .ssr
    )
).generateCSS(for: allPages)
```

## Development

To contribute to WebUI:

1. Clone the repository
2. Build the project: `swift build`
3. Run tests: `swift test`
4. Build documentation: `swift package generate-documentation`

## License

See LICENSE file for details.

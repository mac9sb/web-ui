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

- Use the ``CLI`` tutorial for a quick start with the command-line tool
- See the ``GettingStarted`` tutorial to create your first website from scratch

## Features

### Static Site Generation

Generate complete websites at build time for maximum performance.

### Server-Side Rendering

Render pages dynamically using Hummingbird or other Swift web frameworks.

### Typography

Built-in support for Typst and Markdown content rendering.

## Development Tools

WebUI includes development commands available via `swift run web-ui`:

- **`swift run web-ui init`**: Scaffold a new WebUI project
- **`swift run web-ui build`**: Build your website to static files
- **`swift run web-ui serve`**: Serve a directory with a local HTTP server
- **`swift run web-ui run`**: Build and serve in one command

> Note: WebUI is primarily a Swift library consumed via Swift Package Manager. The CLI commands are development tools, not standalone distributed binaries.

See the ``CLI`` tutorial for detailed usage.

## Modules

- **WebUI**: Core library for HTML generation and website building
- **WebUITypst**: Typst content rendering support
- **WebUIMarkdown**: Markdown content rendering support

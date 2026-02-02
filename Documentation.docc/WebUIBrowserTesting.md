# WebUIBrowserTesting

A Swift-native browser testing library built on WKWebView for WebUI applications. It provides Playwright-style APIs for navigation, element interaction, JavaScript evaluation, and visual regression testing.

## Overview

WebUIBrowserTesting focuses on reliable automation across Apple platforms by leveraging WebKit. It uses Swift concurrency and actors to keep browser and page state thread-safe.

## Topics

- <doc:WebUIBrowserTesting/GettingStarted>
- <doc:WebUIBrowserTesting/SelectorsGuide>
- <doc:WebUIBrowserTesting/WaitingStrategies>
- <doc:WebUIBrowserTesting/SnapshotTesting>
- <doc:WebUIBrowserTesting/BestPractices>
- <doc:WebUIBrowserTesting/Troubleshooting>
- <doc:WebUIBrowserTesting/MigrationGuide>

## Key Capabilities

- **Browser lifecycle**: launch, create pages, close
- **Navigation**: `goto`, `goBack`, `goForward`, `reload`, wait strategies
- **Selectors and interactions**: CSS, XPath, role/text/test-id selectors
- **Input devices**: `page.mouse` for coordinate clicks and `page.touch` for taps
- **JavaScript evaluation**: `evaluate` with argument passing
- **Snapshots**: capture, compare, and manage baselines
- **Events**: console and dialog handling

## Module Structure

- `Core/`: Browser, Page, configuration
- `Elements/`: selectors, element handles, locators
- `JavaScript/`: JS bridge, handles, console messages
- `Interaction/`: keyboard, mouse, and touch helpers
- `Snapshot/`: capture, comparison, storage
- `Testing/`: assertion helpers for swift-testing

## API Stability

The public APIs in this module follow semantic versioning. Breaking changes will be documented in release notes and the migration guide.

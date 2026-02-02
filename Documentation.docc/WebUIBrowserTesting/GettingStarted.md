# Getting Started

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mac9sb/web-ui", from: "1.0.0")
]
```

Add the product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "WebUIBrowserTesting", package: "web-ui")
    ]
)
```

## First Test

```swift
import Testing
import WebUIBrowserTesting

@Test("User can log in")
func testLogin() async throws {
    let browser = Browser()
    try await browser.launch()
    let page = try await browser.newPage()

    try await page.goto("https://example.com/login")
    try await page.fill("#email", "user@test.com")
    try await page.fill("#password", "password123")
    try await page.click("#submit")

    try await page.waitForURL("https://example.com/dashboard")
    #expect(try await page.title() == "Dashboard")

    try await browser.close()
}
```

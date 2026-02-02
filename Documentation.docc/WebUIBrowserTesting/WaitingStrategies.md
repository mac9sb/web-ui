# Waiting Strategies

## Wait for selectors

```swift
let element = try await page.waitForSelector("#dynamic-content")
```

## Wait for conditions

```swift
try await page.waitForFunction("() => document.readyState === 'complete'")
```

## Wait for navigation

```swift
try await page.waitForNavigation {
    try await page.click("#submit")
}
```

## Wait for URL

```swift
try await page.waitForURL("https://example.com/success")
```

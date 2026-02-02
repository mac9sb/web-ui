# Snapshot Testing

## Capture and compare

```swift
let snapshot = try await page.snapshot()
let comparison = snapshot.compare(to: referenceSnapshot, threshold: 0.01)
```

## Expect snapshots

```swift
try await page.expectSnapshot(
    named: "homepage",
    threshold: 0.01,
    snapshotDirectory: ".snapshots"
)
```

## Snapshot options

```swift
let snapshot = try await page.snapshot(options: .init(
    fullPage: false,
    clip: CGRect(x: 0, y: 0, width: 800, height: 600)
))
```

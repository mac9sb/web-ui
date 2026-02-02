# Troubleshooting

## Navigation timeouts

- Increase `NavigationOptions.timeout`.
- Use `waitForLoadState(.domContentLoaded)` when `.load` is too strict.

## Element not found

- Verify the selector in the rendered DOM.
- Prefer `data-testid` and `getByTestId` for stability.

## Snapshot mismatches

- Confirm dynamic content is controlled or hidden.
- Use `SnapshotOptions.clip` to focus on stable regions.

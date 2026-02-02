# Best Practices

- Prefer `waitForSelector` or `waitForFunction` instead of fixed delays.
- Use `data-testid` attributes for stable selectors.
- Reuse a `Browser` across a test suite when possible.
- Keep snapshots deterministic by controlling dynamic content.
- Wrap navigation-triggering actions in `waitForNavigation { ... }`.

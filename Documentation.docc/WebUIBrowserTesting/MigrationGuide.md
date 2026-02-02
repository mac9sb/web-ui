# Migration Guide

## From Playwright

| Playwright | WebUIBrowserTesting |
|-----------|----------------------|
| `await page.goto(url)` | `try await page.goto(url)` |
| `await page.click('#id')` | `try await page.click("#id")` |
| `await page.fill('#id', 'text')` | `try await page.fill("#id", "text")` |
| `await page.evaluate('expr')` | `try await page.evaluate("expr")` |
| `await page.screenshot()` | `try await page.screenshot()` |

## From Puppeteer

The mapping is similar to Playwright. The primary difference is Swift's `async/await` and throwing APIs.

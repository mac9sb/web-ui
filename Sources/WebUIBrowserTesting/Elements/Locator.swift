import Foundation

public struct Locator: Sendable {
    private let page: Page
    private let selector: Selector

    init(page: Page, selector: Selector) {
        self.page = page
        self.selector = selector
    }

    public func first() async -> ElementHandle? {
        await page.querySelector(selector)
    }

    public func all() async -> [ElementHandle] {
        await page.querySelectorAll(selector)
    }
}

import Foundation

public struct Keyboard: Sendable {
    private let page: Page

    init(page: Page) {
        self.page = page
    }

    public func press(_ key: String, modifiers: KeyModifiers = []) async throws {
        let keyLiteral = try JavaScriptString.literal(key)
        let modifiersLiteral = modifiers.jsObjectLiteral
        let script = """
        (() => {
            const target = document.activeElement || document.body;
            if (!target) { return false; }
            const modifiers = \(modifiersLiteral);
            const eventInit = Object.assign({ key: \(keyLiteral), bubbles: true, cancelable: true }, modifiers);
            target.dispatchEvent(new KeyboardEvent('keydown', eventInit));
            target.dispatchEvent(new KeyboardEvent('keyup', eventInit));
            return true;
        })()
        """
        let _: Bool = try await page.evaluate(script)
    }
}

import CoreGraphics
import Foundation

@MainActor
public final class ElementHandle {
    private let page: Page
    private let selector: Selector
    private let index: Int?

    init(page: Page, selector: Selector, index: Int? = nil) {
        self.page = page
        self.selector = selector
        self.index = index
    }

    public func click(options: ClickOptions = .default) async throws {
        let modifiersLiteral = options.modifiers.jsObjectLiteral
        let script = try elementScript {
            """
            const modifiers = \(modifiersLiteral);
            const eventInit = Object.assign({ bubbles: true, cancelable: true, button: 0 }, modifiers);
            el.dispatchEvent(new MouseEvent('mousedown', eventInit));
            el.dispatchEvent(new MouseEvent('mouseup', eventInit));
            el.dispatchEvent(new MouseEvent('click', eventInit));
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
        if let delay = options.delay {
            try await Task.sleep(for: delay)
        }
    }

    public func doubleClick(options: ClickOptions = .default) async throws {
        let modifiersLiteral = options.modifiers.jsObjectLiteral
        let script = try elementScript {
            """
            const modifiers = \(modifiersLiteral);
            const eventInit = Object.assign({ bubbles: true, cancelable: true, button: 0 }, modifiers);
            el.dispatchEvent(new MouseEvent('mousedown', eventInit));
            el.dispatchEvent(new MouseEvent('mouseup', eventInit));
            el.dispatchEvent(new MouseEvent('click', eventInit));
            el.dispatchEvent(new MouseEvent('mousedown', eventInit));
            el.dispatchEvent(new MouseEvent('mouseup', eventInit));
            el.dispatchEvent(new MouseEvent('click', eventInit));
            el.dispatchEvent(new MouseEvent('dblclick', eventInit));
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
        if let delay = options.delay {
            try await Task.sleep(for: delay)
        }
    }

    public func rightClick(options: ClickOptions = .default) async throws {
        let modifiersLiteral = options.modifiers.jsObjectLiteral
        let script = try elementScript {
            """
            const modifiers = \(modifiersLiteral);
            const eventInit = Object.assign({ bubbles: true, cancelable: true, button: 2 }, modifiers);
            el.dispatchEvent(new MouseEvent('mousedown', eventInit));
            el.dispatchEvent(new MouseEvent('mouseup', eventInit));
            el.dispatchEvent(new MouseEvent('contextmenu', eventInit));
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
    }

    public func fill(_ text: String) async throws {
        let literal = try JavaScriptString.literal(text)
        let script = try elementScript {
            """
            el.focus();
            el.value = \(literal);
            el.dispatchEvent(new Event('input', { bubbles: true }));
            el.dispatchEvent(new Event('change', { bubbles: true }));
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
    }

    public func type(_ text: String, options: TypeOptions = .default) async throws {
        let modifiersLiteral = options.modifiers.jsObjectLiteral
        if let delay = options.delay {
            for character in text {
                let literal = try JavaScriptString.literal(String(character))
                let script = try elementScript {
                    """
                    const modifiers = \(modifiersLiteral);
                    const eventInit = Object.assign({ key: \(literal), bubbles: true, cancelable: true }, modifiers);
                    el.focus();
                    el.dispatchEvent(new KeyboardEvent('keydown', eventInit));
                    el.value = (el.value || '') + \(literal);
                    el.dispatchEvent(new Event('input', { bubbles: true }));
                    el.dispatchEvent(new KeyboardEvent('keyup', eventInit));
                    return true;
                    """
                }
                let _: Bool = try await page.evaluate(script)
                try await Task.sleep(for: delay)
            }
        } else {
            for character in text {
                let literal = try JavaScriptString.literal(String(character))
                let script = try elementScript {
                    """
                    const modifiers = \(modifiersLiteral);
                    const eventInit = Object.assign({ key: \(literal), bubbles: true, cancelable: true }, modifiers);
                    el.focus();
                    el.dispatchEvent(new KeyboardEvent('keydown', eventInit));
                    el.value = (el.value || '') + \(literal);
                    el.dispatchEvent(new Event('input', { bubbles: true }));
                    el.dispatchEvent(new KeyboardEvent('keyup', eventInit));
                    return true;
                    """
                }
                let _: Bool = try await page.evaluate(script)
            }
            let script = try elementScript {
                """
                el.dispatchEvent(new Event('change', { bubbles: true }));
                return true;
                """
            }
            let _: Bool = try await page.evaluate(script)
        }
    }

    public func press(_ key: String, modifiers: KeyModifiers = []) async throws {
        let keyLiteral = try JavaScriptString.literal(key)
        let modifiersLiteral = modifiers.jsObjectLiteral
        let script = try elementScript {
            """
            const modifiers = \(modifiersLiteral);
            const eventInit = Object.assign({ key: \(keyLiteral), bubbles: true, cancelable: true }, modifiers);
            el.dispatchEvent(new KeyboardEvent('keydown', eventInit));
            el.dispatchEvent(new KeyboardEvent('keyup', eventInit));
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
    }

    public func clear() async throws {
        let script = try elementScript {
            """
            el.focus();
            el.value = '';
            el.dispatchEvent(new Event('input', { bubbles: true }));
            el.dispatchEvent(new Event('change', { bubbles: true }));
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
    }

    public func check() async throws {
        let script = try elementScript {
            """
            el.checked = true;
            el.dispatchEvent(new Event('change', { bubbles: true }));
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
    }

    public func uncheck() async throws {
        let script = try elementScript {
            """
            el.checked = false;
            el.dispatchEvent(new Event('change', { bubbles: true }));
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
    }

    public func selectOption(_ value: String) async throws {
        let literal = try JavaScriptString.literal(value)
        let script = try elementScript {
            """
            el.value = \(literal);
            el.dispatchEvent(new Event('change', { bubbles: true }));
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
    }

    public func hover() async throws {
        let script = try elementScript {
            """
            const event = new MouseEvent('mouseover', { bubbles: true, cancelable: true });
            el.dispatchEvent(event);
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
    }

    public func focus() async throws {
        let script = try elementScript {
            """
            el.focus();
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
    }

    public func blur() async throws {
        let script = try elementScript {
            """
            el.blur();
            return true;
            """
        }
        let _: Bool = try await page.evaluate(script)
    }

    public func textContent() async throws -> String? {
        let script = try elementScript {
            """
            return el.textContent;
            """
        }
        return try await page.evaluate(script)
    }

    public func innerHTML() async throws -> String? {
        let script = try elementScript {
            """
            return el.innerHTML;
            """
        }
        return try await page.evaluate(script)
    }

    public func value() async throws -> String? {
        let script = try elementScript {
            """
            return el.value ?? null;
            """
        }
        return try await page.evaluate(script)
    }

    public func isVisible() async throws -> Bool {
        let script = try elementScript {
            """
            const style = window.getComputedStyle(el);
            const rect = el.getBoundingClientRect();
            return style && style.display !== 'none' && style.visibility !== 'hidden' && rect.width > 0 && rect.height > 0;
            """
        }
        return try await page.evaluate(script)
    }

    public func isEnabled() async throws -> Bool {
        let script = try elementScript {
            """
            return !el.disabled;
            """
        }
        return try await page.evaluate(script)
    }

    public func getAttribute(_ name: String) async throws -> String? {
        let literal = try JavaScriptString.literal(name)
        let script = try elementScript {
            """
            return el.getAttribute(\(literal));
            """
        }
        return try await page.evaluate(script)
    }

    public func classList() async throws -> [String] {
        let script = try elementScript {
            """
            return Array.from(el.classList);
            """
        }
        return try await page.evaluate(script)
    }

    public func boundingBox() async throws -> CGRect? {
        let script = try elementScript {
            """
            const rect = el.getBoundingClientRect();
            return { x: rect.x, y: rect.y, width: rect.width, height: rect.height };
            """
        }
        let rect: DOMRect? = try await page.evaluate(script)
        guard let rect else { return nil }
        return CGRect(x: rect.x, y: rect.y, width: rect.width, height: rect.height)
    }

    public func screenshot() async throws -> CGImage {
        guard let box = try await boundingBox() else {
            throw BrowserError.elementDetached(description: selector.description)
        }
        return try await page.screenshot(options: ScreenshotOptions(fullPage: false, clip: box))
    }

    public func evaluate<T: Decodable>(_ script: String, args: [Any] = []) async throws -> T {
        guard JSONSerialization.isValidJSONObject(args) else {
            throw BrowserError.internalInconsistency(message: "JavaScript arguments are not valid JSON.")
        }

        let argsData = try JSONSerialization.data(withJSONObject: args, options: [])
        guard let argsJSON = String(data: argsData, encoding: .utf8) else {
            throw BrowserError.internalInconsistency(message: "Failed to encode JavaScript arguments.")
        }

        let elementExpression = try selector.jsElementExpression(index: index)
        let wrappedScript = """
        (() => {
            const el = \(elementExpression);
            if (!el) {
                throw new Error('Element not found');
            }
            const __args = \(argsJSON);
            const __fn = \(script);
            return (typeof __fn === 'function') ? __fn(el, ...__args) : __fn;
        })()
        """
        return try await page.evaluate(wrappedScript)
    }

    public func waitForVisible(
        timeout: Duration = .seconds(5),
        pollingInterval: Duration = .milliseconds(100)
    ) async throws {
        let script = try elementScript {
            """
            const style = window.getComputedStyle(el);
            const rect = el.getBoundingClientRect();
            return style && style.display !== 'none' && style.visibility !== 'hidden' && rect.width > 0 && rect.height > 0;
            """
        }
        try await page.waitForFunction(script, timeout: timeout, pollingInterval: pollingInterval)
    }

    public func waitForEnabled(
        timeout: Duration = .seconds(5),
        pollingInterval: Duration = .milliseconds(100)
    ) async throws {
        let script = try elementScript {
            """
            return !el.disabled;
            """
        }
        try await page.waitForFunction(script, timeout: timeout, pollingInterval: pollingInterval)
    }

    private func elementScript(_ body: () -> String) throws -> String {
        let elementExpression = try selector.jsElementExpression(index: index)
        return """
        (() => {
            const el = \(elementExpression);
            if (!el) {
                throw new Error('Element not found');
            }
            \(body())
        })()
        """
    }
}

public struct ClickOptions: Sendable {
    public var delay: Duration?
    public var modifiers: KeyModifiers

    public init(delay: Duration? = nil, modifiers: KeyModifiers = []) {
        self.delay = delay
        self.modifiers = modifiers
    }

    public static let `default` = ClickOptions()
}

public struct TypeOptions: Sendable {
    public var delay: Duration?
    public var modifiers: KeyModifiers

    public init(delay: Duration? = nil, modifiers: KeyModifiers = []) {
        self.delay = delay
        self.modifiers = modifiers
    }

    public static let `default` = TypeOptions()
}

private struct DOMRect: Decodable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

import CoreGraphics
import Foundation

public enum MouseButton: Int, Sendable {
    case left = 0
    case middle = 1
    case right = 2

    var buttonsMask: Int {
        switch self {
        case .left: return 1
        case .right: return 2
        case .middle: return 4
        }
    }
}

public struct Mouse: Sendable {
    private let page: Page?

    public init() {
        self.page = nil
    }

    init(page: Page) {
        self.page = page
    }

    public func move(to point: CGPoint, modifiers: KeyModifiers = []) async throws {
        let _ = try await dispatch(type: "mousemove", point: point, button: .left, clickCount: 0, modifiers: modifiers, buttonsOverride: 0)
    }

    public func down(at point: CGPoint, button: MouseButton = .left, modifiers: KeyModifiers = []) async throws {
        let _ = try await dispatch(type: "mousedown", point: point, button: button, clickCount: 1, modifiers: modifiers, buttonsOverride: button.buttonsMask)
    }

    public func up(at point: CGPoint, button: MouseButton = .left, modifiers: KeyModifiers = []) async throws {
        let _ = try await dispatch(type: "mouseup", point: point, button: button, clickCount: 1, modifiers: modifiers, buttonsOverride: 0)
    }

    public func click(
        at point: CGPoint,
        button: MouseButton = .left,
        clickCount: Int = 1,
        options: ClickOptions = .default
    ) async throws {
        let modifiers = options.modifiers
        let _ = try await dispatch(type: "mousedown", point: point, button: button, clickCount: clickCount, modifiers: modifiers, buttonsOverride: button.buttonsMask)
        if let delay = options.delay {
            try await Task.sleep(for: delay)
        }
        let _ = try await dispatch(type: "mouseup", point: point, button: button, clickCount: clickCount, modifiers: modifiers, buttonsOverride: 0)
        let _ = try await dispatch(type: "click", point: point, button: button, clickCount: clickCount, modifiers: modifiers, buttonsOverride: 0)
    }

    public func doubleClick(
        at point: CGPoint,
        button: MouseButton = .left,
        options: ClickOptions = .default
    ) async throws {
        try await click(at: point, button: button, clickCount: 1, options: options)
        try await click(at: point, button: button, clickCount: 2, options: options)
        let _ = try await dispatch(type: "dblclick", point: point, button: button, clickCount: 2, modifiers: options.modifiers, buttonsOverride: 0)
    }

    public func rightClick(
        at point: CGPoint,
        options: ClickOptions = .default
    ) async throws {
        let button: MouseButton = .right
        let _ = try await dispatch(type: "mousedown", point: point, button: button, clickCount: 1, modifiers: options.modifiers, buttonsOverride: button.buttonsMask)
        if let delay = options.delay {
            try await Task.sleep(for: delay)
        }
        let _ = try await dispatch(type: "mouseup", point: point, button: button, clickCount: 1, modifiers: options.modifiers, buttonsOverride: 0)
        let _ = try await dispatch(type: "contextmenu", point: point, button: button, clickCount: 1, modifiers: options.modifiers, buttonsOverride: 0)
    }

    public func wheel(at point: CGPoint, deltaX: Double = 0, deltaY: Double) async throws {
        let script = try wheelScript(point: point, deltaX: deltaX, deltaY: deltaY)
        let page = try requirePage()
        let success: Bool = try await page.evaluate(script)
        if !success {
            throw BrowserError.elementNotFound(selector: "point(\(point.x), \(point.y))")
        }
    }

    private func dispatch(
        type: String,
        point: CGPoint,
        button: MouseButton,
        clickCount: Int,
        modifiers: KeyModifiers,
        buttonsOverride: Int?
    ) async throws -> Bool {
        let page = try requirePage()
        let script = try mouseEventScript(
            type: type,
            point: point,
            button: button,
            clickCount: clickCount,
            modifiers: modifiers,
            buttonsOverride: buttonsOverride
        )
        let success: Bool = try await page.evaluate(script)
        if !success {
            throw BrowserError.elementNotFound(selector: "point(\(point.x), \(point.y))")
        }
        return success
    }

    private func requirePage() throws -> Page {
        guard let page else {
            throw BrowserError.webViewNotReady
        }
        return page
    }

    private func mouseEventScript(
        type: String,
        point: CGPoint,
        button: MouseButton,
        clickCount: Int,
        modifiers: KeyModifiers,
        buttonsOverride: Int?
    ) throws -> String {
        let typeLiteral = try JavaScriptString.literal(type)
        let modifiersLiteral = modifiers.jsObjectLiteral
        let buttonValue = button.rawValue
        let buttonsValue = buttonsOverride ?? button.buttonsMask
        let x = point.x
        let y = point.y
        return """
        (() => {
            const target = document.elementFromPoint(\(x), \(y)) || document.body;
            if (!target) { return false; }
            const eventInit = Object.assign({
                bubbles: true,
                cancelable: true,
                detail: \(clickCount),
                button: \(buttonValue),
                buttons: \(buttonsValue),
                clientX: \(x),
                clientY: \(y),
                pageX: \(x) + window.scrollX,
                pageY: \(y) + window.scrollY,
                screenX: \(x),
                screenY: \(y),
                view: window
            }, \(modifiersLiteral));
            target.dispatchEvent(new MouseEvent(\(typeLiteral), eventInit));
            return true;
        })()
        """
    }

    private func wheelScript(point: CGPoint, deltaX: Double, deltaY: Double) throws -> String {
        let x = point.x
        let y = point.y
        return """
        (() => {
            const target = document.elementFromPoint(\(x), \(y)) || document.body;
            if (!target) { return false; }
            const eventInit = {
                bubbles: true,
                cancelable: true,
                clientX: \(x),
                clientY: \(y),
                deltaX: \(deltaX),
                deltaY: \(deltaY),
                deltaMode: 0
            };
            if (typeof WheelEvent !== 'undefined') {
                target.dispatchEvent(new WheelEvent('wheel', eventInit));
            } else {
                target.dispatchEvent(new Event('wheel', { bubbles: true, cancelable: true }));
            }
            return true;
        })()
        """
    }
}

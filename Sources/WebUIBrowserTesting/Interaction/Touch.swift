import CoreGraphics
import Foundation

public struct Touch: Sendable {
    private let page: Page?

    public init() {
        self.page = nil
    }

    init(page: Page) {
        self.page = page
    }

    public func tap(at point: CGPoint, id: Int = 0) async throws {
        try await start(at: point, id: id)
        try await end(at: point, id: id)
    }

    public func start(at point: CGPoint, id: Int = 0) async throws {
        let page = try requirePage()
        let success: Bool = try await page.evaluate(
            try touchEventScript(type: "touchstart", point: point, id: id)
        )
        if !success {
            throw BrowserError.elementNotFound(selector: "point(\(point.x), \(point.y))")
        }
    }

    public func move(to point: CGPoint, id: Int = 0) async throws {
        let page = try requirePage()
        let success: Bool = try await page.evaluate(
            try touchEventScript(type: "touchmove", point: point, id: id)
        )
        if !success {
            throw BrowserError.elementNotFound(selector: "point(\(point.x), \(point.y))")
        }
    }

    public func end(at point: CGPoint, id: Int = 0) async throws {
        let page = try requirePage()
        let success: Bool = try await page.evaluate(
            try touchEventScript(type: "touchend", point: point, id: id)
        )
        if !success {
            throw BrowserError.elementNotFound(selector: "point(\(point.x), \(point.y))")
        }
    }

    private func requirePage() throws -> Page {
        guard let page else {
            throw BrowserError.webViewNotReady
        }
        return page
    }

    private func touchEventScript(type: String, point: CGPoint, id: Int) throws -> String {
        let typeLiteral = try JavaScriptString.literal(type)
        let x = point.x
        let y = point.y
        return """
        (() => {
            const target = document.elementFromPoint(\(x), \(y)) || document.body;
            if (!target) { return false; }
            const supportsTouch = typeof Touch !== 'undefined' && typeof TouchEvent !== 'undefined';
            if (!supportsTouch) {
                const eventInit = { bubbles: true, cancelable: true, clientX: \(x), clientY: \(y), button: 0, buttons: 1 };
                if (\(typeLiteral) === 'touchstart') {
                    target.dispatchEvent(new MouseEvent('mousedown', eventInit));
                } else if (\(typeLiteral) === 'touchmove') {
                    target.dispatchEvent(new MouseEvent('mousemove', eventInit));
                } else {
                    target.dispatchEvent(new MouseEvent('mouseup', eventInit));
                    target.dispatchEvent(new MouseEvent('click', eventInit));
                }
                return true;
            }
            const touch = new Touch({
                identifier: \(id),
                target,
                clientX: \(x),
                clientY: \(y),
                pageX: \(x) + window.scrollX,
                pageY: \(y) + window.scrollY,
                screenX: \(x),
                screenY: \(y)
            });
            const isEnd = \(typeLiteral) === 'touchend' || \(typeLiteral) === 'touchcancel';
            const touches = isEnd ? [] : [touch];
            const eventInit = {
                bubbles: true,
                cancelable: true,
                touches,
                targetTouches: touches,
                changedTouches: [touch]
            };
            target.dispatchEvent(new TouchEvent(\(typeLiteral), eventInit));
            return true;
        })()
        """
    }
}

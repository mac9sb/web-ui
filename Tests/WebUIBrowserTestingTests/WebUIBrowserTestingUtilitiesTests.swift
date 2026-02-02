import CoreGraphics
import Foundation
import Testing

@testable import WebUIBrowserTesting

@Suite("WebUIBrowserTesting Utilities")
struct WebUIBrowserTestingUtilitiesTests {
    @Test("JavaScript string literals round-trip safely")
    func testJavaScriptStringLiteralRoundTrip() throws {
        let original = "Line 1\n\"quoted\" and \\slashes\\"
        let literal = try JavaScriptString.literal(original)
        let decoded = try JSONDecoder().decode(String.self, from: Data(literal.utf8))
        #expect(decoded == original)
    }

    @Test("KeyModifiers builds correct JS modifier object")
    func testKeyModifiersJSObjectLiteral() {
        let modifiers: KeyModifiers = [.shift, .command]
        let literal = modifiers.jsObjectLiteral
        #expect(literal.contains("shiftKey: true"))
        #expect(literal.contains("ctrlKey: false"))
        #expect(literal.contains("altKey: false"))
        #expect(literal.contains("metaKey: true"))
    }

    @Test("Selector descriptions include scoped and role names")
    func testSelectorDescriptions() {
        let selector = Selector.scoped(
            root: .role(.navigation, name: "Main Nav"),
            child: .testId("logout")
        )
        #expect(selector.description.contains("scoped("))
        #expect(selector.description.contains("role(navigation, name: Main Nav)"))
        #expect(selector.description.contains("testId(logout)"))
    }

    @Test("Selector JS expressions include expected query logic")
    func testSelectorJSExpressions() throws {
        let css = try Selector.css("#submit").jsElementExpression()
        #expect(css.contains("querySelector"))
        #expect(css.contains("#submit"))

        let testId = try Selector.testId("login-form").jsElementsExpression()
        #expect(testId.contains("data-testid"))
        #expect(testId.contains("login-form"))

        let role = try Selector.role(.button, name: "Save").jsElementExpression()
        #expect(role.contains("role=\\\"button\\\"") || role.contains("role=\"button\""))
        #expect(role.contains("Save"))
    }

    @Test("Timeout returns result before deadline")
    func testTimeoutSuccess() async throws {
        let result: Int = try await Timeout.withTimeout(
            TimeoutConfiguration(duration: .milliseconds(200), operationDescription: "quick")
        ) {
            42
        }
        #expect(result == 42)
    }

    @Test("Timeout throws when deadline expires")
    func testTimeoutFailure() async {
        do {
            _ = try await Timeout.withTimeout(
                TimeoutConfiguration(duration: .milliseconds(10), operationDescription: "slow")
            ) {
                try await Task.sleep(for: .milliseconds(100))
                return 0
            }
            #expect(false)
        } catch let error as BrowserError {
            switch error {
            case .timeout(let operation, _):
                #expect(operation == "slow")
            default:
                #expect(false)
            }
        } catch {
            #expect(false)
        }
    }

    @Test("Snapshot options provide expected defaults")
    func testSnapshotDefaults() {
        let options = SnapshotOptions.default
        #expect(options.fullPage == true)
        #expect(options.clip == nil)
        #expect(options.omitBackground == false)
        #expect(options.captureBeyondViewport == false)

        let screenshot = ScreenshotOptions.default
        #expect(screenshot.fullPage == true)
        #expect(screenshot.clip == nil)
    }

    @Test("Navigation and browser configuration defaults are sane")
    func testConfigurationDefaults() {
        let nav = NavigationOptions.default
        #expect(nav.waitUntil == .load)
        #expect(nav.timeout != nil)

        let config = BrowserConfiguration.default
        #expect(config.viewportSize.width == 1280)
        #expect(config.viewportSize.height == 720)
        #expect(config.enableJavaScript == true)
        #expect(config.clearStorageOnLaunch == true)
    }

    @Test("Mouse and Touch throw when used without a page")
    func testMouseAndTouchRequirePage() async {
        let mouse = Mouse()
        let touch = Touch()

        do {
            try await mouse.click(at: CGPoint(x: 1, y: 1))
            #expect(false)
        } catch let error as BrowserError {
            #expect(error.localizedDescription.contains("not ready"))
        } catch {
            #expect(false)
        }

        do {
            try await touch.tap(at: CGPoint(x: 1, y: 1))
            #expect(false)
        } catch let error as BrowserError {
            #expect(error.localizedDescription.contains("not ready"))
        } catch {
            #expect(false)
        }
    }

    @Test("Image comparison detects identical and different images")
    func testImageComparison() {
        let red = makeImage(width: 2, height: 2, rgba: (255, 0, 0, 255))
        let red2 = makeImage(width: 2, height: 2, rgba: (255, 0, 0, 255))
        let blue = makeImage(width: 2, height: 2, rgba: (0, 0, 255, 255))

        let identical = ImageComparison.compare(red, red2)
        #expect(identical.percentDifference == 0.0)
        #expect(identical.diffImage != nil)

        let different = ImageComparison.compare(red, blue)
        #expect(different.percentDifference == 1.0)
        #expect(different.diffImage != nil)
    }

    @Test("Snapshot storage saves and loads snapshots")
    func testSnapshotStorageRoundTrip() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("webui-snapshots-\(UUID().uuidString)", isDirectory: true)
        let storage = SnapshotStorage(directory: directory)

        let snapshot = Snapshot(
            image: makeImage(width: 1, height: 1, rgba: (1, 2, 3, 255)),
            metadata: SnapshotMetadata(
                timestamp: Date(timeIntervalSince1970: 1),
                url: "https://example.com",
                viewportSize: CGSize(width: 100, height: 200),
                fullPage: false,
                clip: CGRect(x: 1, y: 2, width: 3, height: 4)
            )
        )

        try storage.saveSnapshot(snapshot, named: "home")
        let loaded = try storage.loadSnapshot(named: "home")

        #expect(loaded.metadata.url == "https://example.com")
        #expect(loaded.metadata.viewportSize.width == 100)
        #expect(loaded.metadata.viewportSize.height == 200)
        #expect(loaded.metadata.fullPage == false)
        #expect(loaded.metadata.clip?.origin.x == 1)
        #expect(loaded.metadata.clip?.size.height == 4)
    }

    @Test("Snapshot manager creates and compares baselines")
    func testSnapshotManagerExpectations() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("webui-snapshot-manager-\(UUID().uuidString)", isDirectory: true)
        let storage = SnapshotStorage(directory: directory)
        let manager = SnapshotManager(storage: storage)

        let first = Snapshot(
            image: makeImage(width: 2, height: 2, rgba: (10, 10, 10, 255)),
            metadata: SnapshotMetadata(
                timestamp: Date(),
                url: nil,
                viewportSize: CGSize(width: 2, height: 2),
                fullPage: true,
                clip: nil
            )
        )

        let created = try manager.expectSnapshot(named: "baseline", snapshot: first, threshold: 0.0)
        #expect(created.percentDifference == 0.0)

        let changed = Snapshot(
            image: makeImage(width: 2, height: 2, rgba: (20, 20, 20, 255)),
            metadata: first.metadata
        )
        let comparison = try manager.expectSnapshot(named: "baseline", snapshot: changed, threshold: 0.0)
        #expect(comparison.percentDifference > 0.0)
    }

    private func makeImage(width: Int, height: Int, rgba: (UInt8, UInt8, UInt8, UInt8)) -> CGImage {
        let pixelCount = width * height
        var bytes = [UInt8](repeating: 0, count: pixelCount * 4)
        for index in stride(from: 0, to: bytes.count, by: 4) {
            bytes[index] = rgba.0
            bytes[index + 1] = rgba.1
            bytes[index + 2] = rgba.2
            bytes[index + 3] = rgba.3
        }
        let bytesPerRow = width * 4
        let data = Data(bytes)
        let provider = CGDataProvider(data: data as CFData)!
        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )!
    }
}

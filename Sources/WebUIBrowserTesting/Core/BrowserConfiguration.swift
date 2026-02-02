import CoreGraphics
import Foundation

public struct BrowserConfiguration: Sendable {
    public var viewportSize: CGSize
    public var userAgent: String?
    public var enableJavaScript: Bool
    public var clearStorageOnLaunch: Bool

    public init(
        viewportSize: CGSize = CGSize(width: 1280, height: 720),
        userAgent: String? = nil,
        enableJavaScript: Bool = true,
        clearStorageOnLaunch: Bool = true
    ) {
        self.viewportSize = viewportSize
        self.userAgent = userAgent
        self.enableJavaScript = enableJavaScript
        self.clearStorageOnLaunch = clearStorageOnLaunch
    }

    public static let `default` = BrowserConfiguration()
}

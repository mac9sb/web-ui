import CoreGraphics
import Foundation

public struct ScreenshotOptions: Sendable {
    public var fullPage: Bool
    public var clip: CGRect?

    public init(fullPage: Bool = true, clip: CGRect? = nil) {
        self.fullPage = fullPage
        self.clip = clip
    }

    public static let `default` = ScreenshotOptions()
}

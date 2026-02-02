import CoreGraphics
import Foundation

public struct SnapshotOptions: Sendable {
    public var fullPage: Bool
    public var clip: CGRect?
    public var omitBackground: Bool
    public var captureBeyondViewport: Bool

    public init(
        fullPage: Bool = true,
        clip: CGRect? = nil,
        omitBackground: Bool = false,
        captureBeyondViewport: Bool = false
    ) {
        self.fullPage = fullPage
        self.clip = clip
        self.omitBackground = omitBackground
        self.captureBeyondViewport = captureBeyondViewport
    }

    public static let `default` = SnapshotOptions()
}

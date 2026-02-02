import CoreGraphics
import Foundation

public struct SnapshotComparison {
    public let percentDifference: Double
    public let diffImage: CGImage?

    public init(percentDifference: Double, diffImage: CGImage?) {
        self.percentDifference = percentDifference
        self.diffImage = diffImage
    }
}

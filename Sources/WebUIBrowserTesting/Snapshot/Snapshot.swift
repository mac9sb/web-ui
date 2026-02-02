import CoreGraphics
import Foundation

public struct Snapshot {
    public let image: CGImage
    public let metadata: SnapshotMetadata

    public init(image: CGImage, metadata: SnapshotMetadata) {
        self.image = image
        self.metadata = metadata
    }

    public func compare(
        to other: Snapshot,
        threshold: Double = 0.0
    ) -> SnapshotComparison {
        let comparison = ImageComparison.compare(image, other.image)
        if comparison.percentDifference <= threshold {
            return SnapshotComparison(percentDifference: comparison.percentDifference, diffImage: nil)
        }
        return comparison
    }
}

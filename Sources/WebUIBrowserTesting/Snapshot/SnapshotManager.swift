import CoreGraphics
import Foundation

public struct SnapshotManager: Sendable {
    public let storage: SnapshotStorage

    public init(storage: SnapshotStorage) {
        self.storage = storage
    }

    public func expectSnapshot(
        named name: String,
        snapshot: Snapshot,
        threshold: Double = 0.0
    ) throws -> SnapshotComparison {
        do {
            let reference = try storage.loadSnapshot(named: name)
            let comparison = snapshot.compare(to: reference, threshold: threshold)
            if comparison.percentDifference > threshold {
                return comparison
            }
            return SnapshotComparison(percentDifference: comparison.percentDifference, diffImage: nil)
        } catch {
            try storage.saveSnapshot(snapshot, named: name)
            return SnapshotComparison(percentDifference: 0.0, diffImage: nil)
        }
    }

    public func saveSnapshot(_ snapshot: Snapshot, named name: String) throws {
        try storage.saveSnapshot(snapshot, named: name)
    }

    public func loadSnapshot(named name: String) throws -> Snapshot {
        try storage.loadSnapshot(named: name)
    }
}

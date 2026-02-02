import Foundation

#if canImport(Testing)
import Testing

public enum Assertions {
    @discardableResult
    public static func expectSnapshot(
        _ comparison: SnapshotComparison,
        threshold: Double
    ) -> Bool {
        let passed = comparison.percentDifference <= threshold
        #expect(passed)
        return passed
    }
}

#else

public enum Assertions {}

#endif

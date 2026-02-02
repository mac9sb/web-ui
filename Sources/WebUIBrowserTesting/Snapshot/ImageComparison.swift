import CoreGraphics
import Foundation

enum ImageComparison {
    static func compare(_ lhs: CGImage, _ rhs: CGImage) -> SnapshotComparison {
        if lhs === rhs {
            return SnapshotComparison(percentDifference: 0.0, diffImage: nil)
        }
        guard lhs.width == rhs.width, lhs.height == rhs.height else {
            return SnapshotComparison(percentDifference: 1.0, diffImage: nil)
        }

        guard let lhsData = rgbaBytes(from: lhs), let rhsData = rgbaBytes(from: rhs) else {
            return SnapshotComparison(percentDifference: 1.0, diffImage: nil)
        }

        let pixelCount = lhs.width * lhs.height
        var diffCount = 0
        var diffBytes = [UInt8](repeating: 0, count: lhsData.count)

        for index in stride(from: 0, to: lhsData.count, by: 4) {
            let r1 = lhsData[index]
            let g1 = lhsData[index + 1]
            let b1 = lhsData[index + 2]
            let a1 = lhsData[index + 3]

            let r2 = rhsData[index]
            let g2 = rhsData[index + 1]
            let b2 = rhsData[index + 2]
            let a2 = rhsData[index + 3]

            if r1 != r2 || g1 != g2 || b1 != b2 || a1 != a2 {
                diffCount += 1
                diffBytes[index] = 255
                diffBytes[index + 1] = 0
                diffBytes[index + 2] = 0
                diffBytes[index + 3] = 255
            }
        }

        let percentDifference = pixelCount > 0 ? Double(diffCount) / Double(pixelCount) : 0
        let diffImage = makeImage(from: diffBytes, width: lhs.width, height: lhs.height)
        return SnapshotComparison(percentDifference: percentDifference, diffImage: diffImage)
    }

    private static func rgbaBytes(from image: CGImage) -> [UInt8]? {
        let width = image.width
        let height = image.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = bytesPerRow * height

        var bytes = [UInt8](repeating: 0, count: totalBytes)
        guard let context = CGContext(
            data: &bytes,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return bytes
    }

    private static func makeImage(from bytes: [UInt8], width: Int, height: Int) -> CGImage? {
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let data = Data(bytes)
        guard let provider = CGDataProvider(data: data as CFData) else {
            return nil
        }

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
        )
    }
}

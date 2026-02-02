import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

public struct SnapshotStorage: Sendable {
    public let directory: URL

    public init(directory: URL) {
        self.directory = directory
    }

    public static func resolveDirectory(_ path: String) -> URL {
        let expanded = (path as NSString).expandingTildeInPath
        if expanded.hasPrefix("/") {
            return URL(fileURLWithPath: expanded, isDirectory: true)
        }
        let cwd = FileManager.default.currentDirectoryPath
        return URL(fileURLWithPath: cwd, isDirectory: true).appendingPathComponent(expanded)
    }

    public func loadSnapshot(named name: String) throws -> Snapshot {
        let imageURL = snapshotImageURL(named: name)
        let metadataURL = snapshotMetadataURL(named: name)

        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            throw BrowserError.snapshotFailed(reason: "Snapshot image not found: \(name)", underlying: nil)
        }
        guard FileManager.default.fileExists(atPath: metadataURL.path) else {
            throw BrowserError.snapshotFailed(reason: "Snapshot metadata not found: \(name)", underlying: nil)
        }

        let image = try readImage(from: imageURL)
        let metadataData = try Data(contentsOf: metadataURL)
        let metadata = try JSONDecoder().decode(SnapshotMetadata.self, from: metadataData)
        return Snapshot(image: image, metadata: metadata)
    }

    public func saveSnapshot(_ snapshot: Snapshot, named name: String) throws {
        try ensureDirectoryExists()
        let imageURL = snapshotImageURL(named: name)
        let metadataURL = snapshotMetadataURL(named: name)

        try writeImage(snapshot.image, to: imageURL)
        let metadataData = try JSONEncoder().encode(snapshot.metadata)
        try metadataData.write(to: metadataURL, options: .atomic)
    }

    public func snapshotImageURL(named name: String) -> URL {
        directory.appendingPathComponent("\(name).png")
    }

    public func snapshotMetadataURL(named name: String) -> URL {
        directory.appendingPathComponent("\(name).json")
    }

    private func ensureDirectoryExists() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private func readImage(from url: URL) throws -> CGImage {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw BrowserError.snapshotFailed(reason: "Failed to read snapshot image", underlying: nil)
        }
        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw BrowserError.snapshotFailed(reason: "Failed to decode snapshot image", underlying: nil)
        }
        return image
    }

    private func writeImage(_ image: CGImage, to url: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw BrowserError.snapshotFailed(reason: "Failed to create snapshot destination", underlying: nil)
        }
        CGImageDestinationAddImage(destination, image, nil)
        if !CGImageDestinationFinalize(destination) {
            throw BrowserError.snapshotFailed(reason: "Failed to write snapshot image", underlying: nil)
        }
    }
}

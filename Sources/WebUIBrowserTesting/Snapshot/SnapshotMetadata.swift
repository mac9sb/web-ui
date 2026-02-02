import CoreGraphics
import Foundation

public struct SnapshotMetadata: Codable {
    public let timestamp: Date
    public let url: String?
    public let viewportSize: CGSize
    public let fullPage: Bool
    public let clip: CGRect?

    public init(
        timestamp: Date,
        url: String?,
        viewportSize: CGSize,
        fullPage: Bool,
        clip: CGRect?
    ) {
        self.timestamp = timestamp
        self.url = url
        self.viewportSize = viewportSize
        self.fullPage = fullPage
        self.clip = clip
    }

    private enum CodingKeys: String, CodingKey {
        case timestamp
        case url
        case viewportSize
        case fullPage
        case clip
    }

    private struct CodableSize: Codable {
        let width: Double
        let height: Double
    }

    private struct CodableRect: Codable {
        let x: Double
        let y: Double
        let width: Double
        let height: Double
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        let size = try container.decode(CodableSize.self, forKey: .viewportSize)
        viewportSize = CGSize(width: size.width, height: size.height)
        fullPage = try container.decode(Bool.self, forKey: .fullPage)
        if let rect = try container.decodeIfPresent(CodableRect.self, forKey: .clip) {
            clip = CGRect(x: rect.x, y: rect.y, width: rect.width, height: rect.height)
        } else {
            clip = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encode(CodableSize(width: viewportSize.width, height: viewportSize.height), forKey: .viewportSize)
        try container.encode(fullPage, forKey: .fullPage)
        if let clip {
            try container.encode(CodableRect(x: clip.origin.x, y: clip.origin.y, width: clip.size.width, height: clip.size.height), forKey: .clip)
        }
    }
}

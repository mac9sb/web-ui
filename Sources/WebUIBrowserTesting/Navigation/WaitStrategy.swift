import Foundation

public enum WaitStrategy: String, Sendable {
    case load
    case domContentLoaded
    case networkIdle
}

import Foundation

public struct NavigationOptions: Sendable {
    public var waitUntil: WaitStrategy
    public var timeout: Duration?

    public init(waitUntil: WaitStrategy = .load, timeout: Duration? = .seconds(30)) {
        self.waitUntil = waitUntil
        self.timeout = timeout
    }

    public static let `default` = NavigationOptions()
}

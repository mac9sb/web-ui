import Foundation

/// Style operation for group and peer marker classes
///
/// These marker classes enable group-hover, group-focus, peer-hover, etc. styling
/// on child or sibling elements.
public struct GroupStyleOperation: StyleOperation, @unchecked Sendable {
    /// Parameters for group styling
    public struct Parameters {
        /// Whether to apply the group class
        public let isGroup: Bool
        /// Whether to apply the peer class
        public let isPeer: Bool

        /// Creates parameters for group/peer styling
        public init(isGroup: Bool = false, isPeer: Bool = false) {
            self.isGroup = isGroup
            self.isPeer = isPeer
        }
    }

    /// Applies the group/peer style and returns the appropriate stylesheet classes
    public func applyClasses(params: Parameters) -> [String] {
        var classes: [String] = []
        if params.isGroup {
            classes.append("group")
        }
        if params.isPeer {
            classes.append("peer")
        }
        return classes
    }

    /// Shared instance for use across the framework
    public static let shared = GroupStyleOperation()

    /// Private initializer to enforce singleton usage
    private init() {}
}

// Extension for Markup to provide group/peer styling
extension Markup {
    /// Marks the element as a group container for group-hover, group-focus, etc.
    ///
    /// Child elements can use `.on { $0.groupHover { ... } }` to respond to
    /// hover events on this parent element.
    ///
    /// ## Example
    /// ```swift
    /// Link(to: "/") {
    ///     Icon()
    ///         .on { $0.groupHover { $0.invert() } }
    /// }
    /// .group()
    /// .on { $0.hover { $0.background(color: .black()) } }
    /// ```
    public func group() -> some Markup {
        let params = GroupStyleOperation.Parameters(isGroup: true)
        return GroupStyleOperation.shared.applyTo(self, params: params)
    }

    /// Marks the element as a peer for peer-hover, peer-focus, etc.
    ///
    /// Sibling elements that come after can use `.on { $0.peerHover { ... } }`
    /// to respond to hover events on this element.
    ///
    /// ## Example
    /// ```swift
    /// Input()
    ///     .peer()
    /// Label()
    ///     .on { $0.peerFocus { $0.font(color: .blue()) } }
    /// ```
    public func peer() -> some Markup {
        let params = GroupStyleOperation.Parameters(isPeer: true)
        return GroupStyleOperation.shared.applyTo(self, params: params)
    }
}

import Foundation

/// Style operation for grid container styling
///
/// Provides a unified implementation for grid styling that can be used across
/// Element methods and the Declarative DSL functions.
public struct GridStyleOperation: StyleOperation, @unchecked Sendable {
    /// Parameters for grid styling
    public struct Parameters {
        /// The number of grid columns
        public let columns: Int?

        /// The number of grid rows
        public let rows: Int?

        /// The grid flow direction
        public let flow: GridFlow?

        /// The column span value
        public let columnSpan: Int?

        /// The row span value
        public let rowSpan: Int?

        /// The gap between grid items (in spacing units)
        public let gap: Int?

        /// The starting column position
        public let columnStart: Int?

        /// The starting row position
        public let rowStart: Int?

        /// Creates parameters for grid styling
        ///
        /// - Parameters:
        ///   - columns: The number of grid columns
        ///   - rows: The number of grid rows
        ///   - flow: The grid flow direction
        ///   - columnSpan: The column span value
        ///   - rowSpan: The row span value
        ///   - gap: The gap between grid items
        ///   - columnStart: The starting column position
        ///   - rowStart: The starting row position
        public init(
            columns: Int? = nil,
            rows: Int? = nil,
            flow: GridFlow? = nil,
            columnSpan: Int? = nil,
            rowSpan: Int? = nil,
            gap: Int? = nil,
            columnStart: Int? = nil,
            rowStart: Int? = nil
        ) {
            self.columns = columns
            self.rows = rows
            self.flow = flow
            self.columnSpan = columnSpan
            self.rowSpan = rowSpan
            self.gap = gap
            self.columnStart = columnStart
            self.rowStart = rowStart
        }

        /// Creates parameters from a StyleParameters container
        ///
        /// - Parameter params: The style parameters container
        /// - Returns: GridStyleOperation.Parameters
        public static func from(_ params: StyleParameters) -> Parameters {
            Parameters(
                columns: params.get("columns"),
                rows: params.get("rows"),
                flow: params.get("flow"),
                columnSpan: params.get("columnSpan"),
                rowSpan: params.get("rowSpan"),
                gap: params.get("gap"),
                columnStart: params.get("columnStart"),
                rowStart: params.get("rowStart")
            )
        }
    }

    /// Applies the grid style and returns the appropriate stylesheet classes
    ///
    /// - Parameter params: The parameters for grid styling
    /// - Returns: An array of stylesheet class names to be applied to elements
    public func applyClasses(params: Parameters) -> [String] {
        var classes: [String] = []

        // Only add "grid" if we're defining a grid container (with columns/rows)
        if params.columns != nil || params.rows != nil {
            classes.append("grid")
        }

        if let columns = params.columns {
            classes.append("grid-cols-\(columns)")
        }

        if let rows = params.rows {
            classes.append("grid-rows-\(rows)")
        }

        if let flow = params.flow {
            classes.append("grid-flow-\(flow.rawValue)")
        }

        if let columnSpan = params.columnSpan {
            classes.append("col-span-\(columnSpan)")
        }

        if let rowSpan = params.rowSpan {
            classes.append("row-span-\(rowSpan)")
        }

        if let gap = params.gap {
            classes.append("gap-\(gap)")
        }

        if let columnStart = params.columnStart {
            classes.append("col-start-\(columnStart)")
        }

        if let rowStart = params.rowStart {
            classes.append("row-start-\(rowStart)")
        }

        return classes
    }

    /// Shared instance for use across the framework
    public static let shared = GridStyleOperation()

    /// Private initializer to enforce singleton usage
    private init() {}
}

/// Defines the grid flow direction
public enum GridFlow: String {
    /// Items flow row by row
    case row

    /// Items flow column by column
    case col

    /// Items flow row by row, dense packing
    case rowDense = "row-dense"

    /// Items flow column by column, dense packing
    case colDense = "col-dense"
}

// Extension for HTML to provide grid styling
extension Markup {
    /// Sets grid container properties with optional modifiers.
    ///
    /// - Parameters:
    ///   - columns: The number of grid columns.
    ///   - rows: The number of grid rows.
    ///   - flow: The grid flow direction.
    ///   - columnSpan: The column span value.
    ///   - rowSpan: The row span value.
    ///   - gap: The gap between grid items.
    ///   - columnStart: The starting column position.
    ///   - rowStart: The starting row position.
    ///   - modifiers: Zero or more modifiers (e.g., `.hover`, `.md`) to scope the styles.
    /// - Returns: Markup with updated grid classes.
    ///
    /// ## Example
    /// ```swift
    /// // Create a grid container with 3 columns
    /// Stack()(tag: "div").grid(columns: 3)
    ///
    /// // Create a grid container with 2 columns and 3 rows
    /// Stack()(tag: "div").grid(columns: 2, rows: 3)
    ///
    /// // Apply grid layout only on medium screens and up
    /// Stack()(tag: "div").grid(columns: 2, on: .md)
    ///
    /// // Create a grid with gap
    /// Stack()(tag: "div").grid(columns: 3, gap: 4, on: .lg)
    /// ```
    public func grid(
        columns: Int? = nil,
        rows: Int? = nil,
        flow: GridFlow? = nil,
        columnSpan: Int? = nil,
        rowSpan: Int? = nil,
        gap: Int? = nil,
        columnStart: Int? = nil,
        rowStart: Int? = nil,
        on modifiers: Modifier...
    ) -> some Markup {
        let params = GridStyleOperation.Parameters(
            columns: columns,
            rows: rows,
            flow: flow,
            columnSpan: columnSpan,
            rowSpan: rowSpan,
            gap: gap,
            columnStart: columnStart,
            rowStart: rowStart
        )

        return GridStyleOperation.shared.applyTo(
            self,
            params: params,
            modifiers: modifiers
        )
    }
}

// Extension for ResponsiveBuilder to provide grid styling
extension ResponsiveBuilder {
    /// Sets grid container properties in a responsive context.
    ///
    /// - Parameters:
    ///   - columns: The number of grid columns.
    ///   - rows: The number of grid rows.
    ///   - flow: The grid flow direction.
    ///   - columnSpan: The column span value.
    ///   - rowSpan: The row span value.
    ///   - gap: The gap between grid items.
    ///   - columnStart: The starting column position.
    ///   - rowStart: The starting row position.
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func grid(
        columns: Int? = nil,
        rows: Int? = nil,
        flow: GridFlow? = nil,
        columnSpan: Int? = nil,
        rowSpan: Int? = nil,
        gap: Int? = nil,
        columnStart: Int? = nil,
        rowStart: Int? = nil
    ) -> ResponsiveBuilder {
        let params = GridStyleOperation.Parameters(
            columns: columns,
            rows: rows,
            flow: flow,
            columnSpan: columnSpan,
            rowSpan: rowSpan,
            gap: gap,
            columnStart: columnStart,
            rowStart: rowStart
        )

        return GridStyleOperation.shared.applyToBuilder(self, params: params)
    }
}

// Global function for Declarative DSL
/// Sets grid container properties in the responsive context.
///
/// - Parameters:
///   - columns: The number of grid columns.
///   - rows: The number of grid rows.
///   - flow: The grid flow direction.
///   - columnSpan: The column span value.
///   - rowSpan: The row span value.
///   - gap: The gap between grid items.
///   - columnStart: The starting column position.
///   - rowStart: The starting row position.
/// - Returns: A responsive modification for grid container.
public func grid(
    columns: Int? = nil,
    rows: Int? = nil,
    flow: GridFlow? = nil,
    columnSpan: Int? = nil,
    rowSpan: Int? = nil,
    gap: Int? = nil,
    columnStart: Int? = nil,
    rowStart: Int? = nil
) -> ResponsiveModification {
    let params = GridStyleOperation.Parameters(
        columns: columns,
        rows: rows,
        flow: flow,
        columnSpan: columnSpan,
        rowSpan: rowSpan,
        gap: gap,
        columnStart: columnStart,
        rowStart: rowStart
    )

    return GridStyleOperation.shared.asModification(params: params)
}

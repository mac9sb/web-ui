import Foundation

/// Generates CSS rules from utility class names.
///
/// CSSGenerator parses utility class names (e.g., "bg-blue-500", "hover:opacity-50")
/// and produces corresponding CSS rules for compile-time stylesheet generation.
///
/// ## Architecture
///
/// The generator uses a rule-based system where each utility pattern (background,
/// padding, font, etc.) has a corresponding CSS rule generator. Modifiers (hover,
/// responsive, etc.) are handled through prefix parsing.
///
/// ## Supported Patterns
///
/// - **Colors**: `bg-{color}-{shade}`, `text-{color}-{shade}`, `border-{color}-{shade}`
/// - **Spacing**: `p-{size}`, `m-{size}`, `px-{size}`, `py-{size}`, etc.
/// - **Sizing**: `w-{size}`, `h-{size}`, `max-w-{size}`, `min-h-{size}`
/// - **Typography**: `text-{size}`, `font-{weight}`, `text-{align}`
/// - **Flexbox**: `flex`, `flex-col`, `justify-{value}`, `items-{value}`
/// - **Grid**: `grid`, `grid-cols-{n}`, `gap-{size}`
/// - **Modifiers**: `hover:`, `focus:`, `md:`, `lg:`, etc.
///
/// ## Example
///
/// ```swift
/// let classes = ["bg-blue-500", "hover:bg-blue-600", "p-4", "md:p-8"]
/// let css = CSSGenerator.generateCSS(for: classes)
/// // Produces:
/// // .bg-blue-500 { background-color: rgb(59 130 246); }
/// // .hover\:bg-blue-600:hover { background-color: rgb(37 99 235); }
/// // .p-4 { padding: 1rem; }
/// // @media (min-width: 768px) { .md\:p-8 { padding: 2rem; } }
/// ```
///
/// - SeeAlso: ``ClassCollector``
public enum CSSGenerator {
    /// Generates CSS from an array of utility class names.
    ///
    /// - Parameter classes: Array of utility class names
    /// - Returns: A string containing CSS rules
    public static func generateCSS(for classes: [String]) -> String {
        var cssRules: [String] = []
        var mediaQueries: [String: [String]] = [:]

        for className in classes {
            // Parse modifiers (hover:, focus:, md:, lg:, etc.)
            let (modifiers, baseClass) = parseModifiers(from: className)

            // Generate CSS rule
            if let rule = generateRule(for: baseClass, modifiers: modifiers) {
                // Check if this is a responsive rule
                if let breakpoint = modifiers.first(where: { isBreakpoint($0) }) {
                    let mediaQuery = breakpointToMediaQuery(breakpoint)
                    if mediaQueries[mediaQuery] == nil {
                        mediaQueries[mediaQuery] = []
                    }
                    mediaQueries[mediaQuery]?.append(rule)
                } else {
                    cssRules.append(rule)
                }
            }
        }

        // Build final CSS with reset
        let cssReset = """
        * { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; }
        a { text-decoration: none; color: inherit; }
        summary { transition: transform 0.3s ease-in-out; }
        details.group[open] > summary { transform: rotate(-180deg); }
        """

        var result = cssReset + "\n" + cssRules.joined(separator: "\n")

        // Add media queries
        for (mediaQuery, rules) in mediaQueries.sorted(by: { $0.key < $1.key }) {
            result += "\n\(mediaQuery) {\n  " + rules.joined(separator: "\n  ") + "\n}"
        }

        return result
    }

    /// Parses modifiers from a class name.
    ///
    /// - Parameter className: Full class name (e.g., "hover:md:bg-blue-500")
    /// - Returns: Tuple of (modifiers, baseClass)
    private static func parseModifiers(from className: String) -> ([String], String) {
        let parts = className.split(separator: ":").map(String.init)
        guard parts.count > 1 else {
            return ([], className)
        }
        return (Array(parts.dropLast()), parts.last!)
    }

    /// Checks if a modifier is a responsive breakpoint.
    ///
    /// - Parameter modifier: Modifier string (e.g., "md", "lg")
    /// - Returns: True if the modifier is a breakpoint
    private static func isBreakpoint(_ modifier: String) -> Bool {
        ["xs", "sm", "md", "lg", "xl", "2xl"].contains(modifier)
    }

    /// Converts a breakpoint to a media query.
    ///
    /// - Parameter breakpoint: Breakpoint name (e.g., "md")
    /// - Returns: Media query string
    private static func breakpointToMediaQuery(_ breakpoint: String) -> String {
        let breakpoints: [String: String] = [
            "xs": "(min-width: 480px)",
            "sm": "(min-width: 640px)",
            "md": "(min-width: 768px)",
            "lg": "(min-width: 1024px)",
            "xl": "(min-width: 1280px)",
            "2xl": "(min-width: 1536px)",
        ]
        return "@media " + (breakpoints[breakpoint] ?? "(min-width: 0px)")
    }

    /// Generates a CSS rule for a utility class.
    ///
    /// - Parameters:
    ///   - baseClass: The base class name without modifiers
    ///   - modifiers: Array of modifier strings
    /// - Returns: CSS rule string, or nil if the class cannot be parsed
    private static func generateRule(for baseClass: String, modifiers: [String]) -> String? {
        // Build selector with modifiers
        let selector = buildSelector(for: baseClass, modifiers: modifiers)

        // Generate CSS properties based on class pattern
        guard let properties = generateProperties(for: baseClass) else {
            return nil
        }

        return ".\(selector) { \(properties) }"
    }

    /// Builds a CSS selector with modifiers.
    ///
    /// - Parameters:
    ///   - baseClass: The base class name
    ///   - modifiers: Array of modifier strings
    /// - Returns: Escaped selector string
    private static func buildSelector(for baseClass: String, modifiers: [String]) -> String {
        var selector = baseClass
            .replacingOccurrences(of: "#", with: "\\#")
            .replacingOccurrences(of: "[", with: "\\[")
            .replacingOccurrences(of: "]", with: "\\]")
            .replacingOccurrences(of: ":", with: "\\:")

        // Add all modifiers to the selector (including breakpoints)
        // Breakpoints get media queries, but still need to be in the class name
        for modifier in modifiers.reversed() {  // Reversed to maintain order: md:hover:flex
            selector = "\(modifier)\\:\(selector)"

            // Add pseudo-class selectors for state modifiers
            if !isBreakpoint(modifier) {
                switch modifier {
                case "hover": selector += ":hover"
                case "focus": selector += ":focus"
                case "active": selector += ":active"
                case "disabled": selector += ":disabled"
                case "group-hover": selector = "group:hover \(selector)"
                case "group-focus": selector = "group:focus \(selector)"
                case "peer-hover": selector = "peer:hover ~ \(selector)"
                case "peer-focus": selector = "peer:focus ~ \(selector)"
                case "peer-checked": selector = "peer:checked ~ \(selector)"
                default: break
                }
            }
        }

        return selector
    }

    /// Generates CSS properties for a utility class.
    ///
    /// - Parameter baseClass: The base class name
    /// - Returns: CSS property-value pairs, or nil if unsupported
    private static func generateProperties(for baseClass: String) -> String? {
        // Display utilities
        if baseClass == "block" { return "display: block;" }
        if baseClass == "inline-block" { return "display: inline-block;" }
        if baseClass == "inline" { return "display: inline;" }
        if baseClass == "flex" { return "display: flex;" }
        if baseClass == "inline-flex" { return "display: inline-flex;" }
        if baseClass == "grid" { return "display: grid;" }
        if baseClass == "inline-grid" { return "display: inline-grid;" }
        if baseClass == "table" { return "display: table;" }
        if baseClass == "table-cell" { return "display: table-cell;" }
        if baseClass == "table-row" { return "display: table-row;" }
        if baseClass == "hidden" { return "display: none;" }

        // Group class (allowed but generates no CSS)
        if baseClass == "group" { return nil }

        // Flexbox direction
        if baseClass == "flex-row" { return "flex-direction: row;" }
        if baseClass == "flex-col" { return "flex-direction: column;" }
        if baseClass == "flex-row-reverse" { return "flex-direction: row-reverse;" }
        if baseClass == "flex-col-reverse" { return "flex-direction: column-reverse;" }

        // Flexbox wrap
        if baseClass == "flex-wrap" { return "flex-wrap: wrap;" }
        if baseClass == "flex-nowrap" { return "flex-wrap: nowrap;" }
        if baseClass == "flex-wrap-reverse" { return "flex-wrap: wrap-reverse;" }

        // Flexbox grow
        if baseClass == "flex-0" { return "flex: 0 1 0%;" }
        if baseClass == "flex-1" { return "flex: 1 1 0%;" }

        // Flexbox justify
        if baseClass.hasPrefix("justify-") {
            if let value = parseFlexJustify(from: baseClass) {
                return "justify-content: \(value);"
            }
        }

        // Flexbox align
        if baseClass.hasPrefix("items-") {
            if let value = parseFlexAlign(from: baseClass) {
                return "align-items: \(value);"
            }
        }

        // Grid
        if baseClass.hasPrefix("grid-cols-") {
            if let cols = parseGridCols(from: baseClass) {
                return "grid-template-columns: repeat(\(cols), minmax(0, 1fr));"
            }
        }
        if baseClass.hasPrefix("grid-rows-") {
            if let rows = parseGridRows(from: baseClass) {
                return "grid-template-rows: repeat(\(rows), minmax(0, 1fr));"
            }
        }
        if baseClass.hasPrefix("col-span-") {
            if let span = parseGridSpan(from: baseClass, prefix: "col-span-") {
                return "grid-column: span \(span) / span \(span);"
            }
        }
        if baseClass.hasPrefix("row-span-") {
            if let span = parseGridSpan(from: baseClass, prefix: "row-span-") {
                return "grid-row: span \(span) / span \(span);"
            }
        }
        if baseClass.hasPrefix("col-start-") {
            if let start = parseGridStart(from: baseClass, prefix: "col-start-") {
                return "grid-column-start: \(start);"
            }
        }
        if baseClass.hasPrefix("row-start-") {
            if let start = parseGridStart(from: baseClass, prefix: "row-start-") {
                return "grid-row-start: \(start);"
            }
        }
        if baseClass.hasPrefix("grid-flow-") {
            if let flow = parseGridFlow(from: baseClass) {
                return "grid-auto-flow: \(flow);"
            }
        }
        if baseClass.hasPrefix("gap-") {
            if let gap = parseGap(from: baseClass) {
                return "gap: \(gap);"
            }
        }

        // Position
        if baseClass == "static" { return "position: static;" }
        if baseClass == "fixed" { return "position: fixed;" }
        if baseClass == "absolute" { return "position: absolute;" }
        if baseClass == "relative" { return "position: relative;" }
        if baseClass == "sticky" { return "position: sticky;" }

        // Inset
        if baseClass == "inset-0" { return "top: 0; right: 0; bottom: 0; left: 0;" }
        if baseClass == "inset-px" { return "top: 1px; right: 1px; bottom: 1px; left: 1px;" }
        if baseClass == "inset-auto" { return "top: auto; right: auto; bottom: auto; left: auto;" }
        if baseClass == "inset-full" { return "top: 100%; right: 100%; bottom: 100%; left: 100%;" }

        // Individual inset positions
        if baseClass.hasPrefix("top-") || baseClass.hasPrefix("left-") ||
           baseClass.hasPrefix("right-") || baseClass.hasPrefix("bottom-") ||
           baseClass.hasPrefix("inset-x-") || baseClass.hasPrefix("inset-y-") {
            if let inset = parseInset(from: baseClass) {
                return inset
            }
        }

        // Z-index
        if baseClass.hasPrefix("z-") {
            if let zIndex = parseZIndex(from: baseClass) {
                return "z-index: \(zIndex);"
            }
        }

        // Width/Height
        if baseClass.hasPrefix("w-") {
            if let width = parseSizing(from: baseClass, prefix: "w-") {
                return "width: \(width);"
            }
        }
        if baseClass.hasPrefix("h-") {
            if let height = parseSizing(from: baseClass, prefix: "h-") {
                return "height: \(height);"
            }
        }
        if baseClass.hasPrefix("min-w-") {
            if let minWidth = parseSizing(from: baseClass, prefix: "min-w-") {
                return "min-width: \(minWidth);"
            }
        }
        if baseClass.hasPrefix("min-h-") {
            if let minHeight = parseSizing(from: baseClass, prefix: "min-h-") {
                return "min-height: \(minHeight);"
            }
        }
        if baseClass.hasPrefix("max-w-") {
            if let maxWidth = parseSizing(from: baseClass, prefix: "max-w-") {
                return "max-width: \(maxWidth);"
            }
        }
        if baseClass.hasPrefix("max-h-") {
            if let maxHeight = parseSizing(from: baseClass, prefix: "max-h-") {
                return "max-height: \(maxHeight);"
            }
        }

        // Padding
        if baseClass.hasPrefix("p-") || baseClass.hasPrefix("px-") || baseClass.hasPrefix("py-") ||
           baseClass.hasPrefix("pt-") || baseClass.hasPrefix("pr-") || baseClass.hasPrefix("pb-") || baseClass.hasPrefix("pl-") {
            if let spacing = parseSpacing(from: baseClass) {
                return spacing
            }
        }

        // Margin
        if baseClass.hasPrefix("m-") || baseClass.hasPrefix("mx-") || baseClass.hasPrefix("my-") ||
           baseClass.hasPrefix("mt-") || baseClass.hasPrefix("mr-") || baseClass.hasPrefix("mb-") || baseClass.hasPrefix("ml-") {
            if let spacing = parseSpacing(from: baseClass) {
                return spacing
            }
        }

        // Typography - Font Size
        if baseClass.hasPrefix("text-") && !baseClass.hasPrefix("text-[") {
            if let fontSize = parseFontSize(from: baseClass) {
                return fontSize
            }
            // Also check for text color
            if let color = parseColor(from: baseClass, prefix: "text-") {
                return "color: \(color);"
            }
        }

        // Font Weight
        if baseClass.hasPrefix("font-") && !baseClass.hasPrefix("font-[") {
            if let fontWeight = parseFontWeight(from: baseClass) {
                return "font-weight: \(fontWeight);"
            }
            // Also check for font family
            if let fontFamily = parseFontFamily(from: baseClass) {
                return "font-family: \(fontFamily);"
            }
        }

        // Leading (line-height)
        if baseClass.hasPrefix("leading-") {
            if let lineHeight = parseLineHeight(from: baseClass) {
                return "line-height: \(lineHeight);"
            }
        }

        // Background colors
        if baseClass.hasPrefix("bg-") {
            if let color = parseColor(from: baseClass, prefix: "bg-") {
                return "background-color: \(color);"
            }
        }

        // Border colors
        if baseClass.hasPrefix("border-") && !baseClass.contains("border-t") && !baseClass.contains("border-b") && !baseClass.contains("border-l") && !baseClass.contains("border-r") {
            // Check for border width first
            if let borderWidth = parseBorderWidth(from: baseClass) {
                return borderWidth
            }
            // Then check for border color
            if let color = parseColor(from: baseClass, prefix: "border-") {
                return "border-color: \(color);"
            }
        }

        // Border sides
        if baseClass == "border-t" { return "border-top-width: 1px; border-top-style: solid;" }
        if baseClass == "border-b" { return "border-bottom-width: 1px; border-bottom-style: solid;" }
        if baseClass == "border-l" { return "border-left-width: 1px; border-left-style: solid;" }
        if baseClass == "border-r" { return "border-right-width: 1px; border-right-style: solid;" }
        if baseClass == "border" { return "border-width: 1px; border-style: solid;" }

        // Border radius
        if baseClass.hasPrefix("rounded") {
            if let radius = parseBorderRadius(from: baseClass) {
                return radius
            }
        }

        // Shadow
        if baseClass.hasPrefix("shadow") {
            if let shadow = parseShadow(from: baseClass) {
                return shadow
            }
        }

        // Tracking (letter-spacing)
        if baseClass.hasPrefix("tracking-") {
            if let tracking = parseTracking(from: baseClass) {
                return "letter-spacing: \(tracking);"
            }
        }

        // Text decoration
        if baseClass == "underline" { return "text-decoration: underline;" }
        if baseClass == "overline" { return "text-decoration: overline;" }
        if baseClass == "line-through" { return "text-decoration: line-through;" }
        if baseClass == "no-underline" { return "text-decoration: none;" }

        // Text decoration style
        if baseClass == "decoration-solid" { return "text-decoration-style: solid;" }
        if baseClass == "decoration-double" { return "text-decoration-style: double;" }
        if baseClass == "decoration-dotted" { return "text-decoration-style: dotted;" }
        if baseClass == "decoration-dashed" { return "text-decoration-style: dashed;" }
        if baseClass == "decoration-wavy" { return "text-decoration-style: wavy;" }

        // Text alignment
        if baseClass == "text-left" { return "text-align: left;" }
        if baseClass == "text-center" { return "text-align: center;" }
        if baseClass == "text-right" { return "text-align: right;" }
        if baseClass == "text-justify" { return "text-align: justify;" }

        // Text wrapping
        if baseClass == "text-wrap" { return "text-wrap: wrap;" }
        if baseClass == "text-nowrap" { return "text-wrap: nowrap;" }
        if baseClass == "text-balance" { return "text-wrap: balance;" }
        if baseClass == "text-pretty" { return "text-wrap: pretty;" }

        // Vertical alignment
        if baseClass.hasPrefix("align-") {
            if let align = parseVerticalAlign(from: baseClass) {
                return "vertical-align: \(align);"
            }
        }

        // Whitespace
        if baseClass == "whitespace-nowrap" { return "white-space: nowrap;" }
        if baseClass == "whitespace-normal" { return "white-space: normal;" }
        if baseClass == "whitespace-pre" { return "white-space: pre;" }
        if baseClass == "whitespace-pre-line" { return "white-space: pre-line;" }
        if baseClass == "whitespace-pre-wrap" { return "white-space: pre-wrap;" }

        // List style
        if baseClass == "list-none" { return "list-style-type: none;" }
        if baseClass == "list-disc" { return "list-style-type: disc;" }
        if baseClass == "list-decimal" { return "list-style-type: decimal;" }

        // Overflow
        if baseClass == "overflow-hidden" { return "overflow: hidden;" }
        if baseClass == "overflow-auto" { return "overflow: auto;" }
        if baseClass == "overflow-visible" { return "overflow: visible;" }
        if baseClass == "overflow-scroll" { return "overflow: scroll;" }

        // Pointer events
        if baseClass == "pointer-events-none" { return "pointer-events: none;" }
        if baseClass == "pointer-events-auto" { return "pointer-events: auto;" }

        // Cursor
        if baseClass == "cursor-pointer" { return "cursor: pointer;" }
        if baseClass == "cursor-default" { return "cursor: default;" }
        if baseClass == "cursor-not-allowed" { return "cursor: not-allowed;" }

        // Transitions
        if baseClass.hasPrefix("transition") {
            if let transition = parseTransition(from: baseClass) {
                return transition
            }
        }
        if baseClass.hasPrefix("duration-") {
            if let duration = parseDuration(from: baseClass) {
                return "transition-duration: \(duration);"
            }
        }
        if baseClass.hasPrefix("ease-") {
            if let easing = parseEasing(from: baseClass) {
                return "transition-timing-function: \(easing);"
            }
        }

        // Transforms
        if baseClass.hasPrefix("rotate-") {
            if let rotation = parseRotation(from: baseClass) {
                return "transform: rotate(\(rotation));"
            }
        }

        // Opacity
        if baseClass.hasPrefix("opacity-") {
            if let opacity = parseOpacity(from: baseClass) {
                return "opacity: \(opacity);"
            }
        }

        // Arbitrary values (e.g., bg-[#020617], text-[#F8FAFC], font-[system-ui])
        if baseClass.contains("[") && baseClass.contains("]") {
            if let arbitraryValue = parseArbitraryValue(from: baseClass) {
                return arbitraryValue
            }
        }

        // Unsupported class - return nil
        return nil
    }

    /// Parses a color value from a utility class.
    ///
    /// - Parameters:
    ///   - className: Full class name
    ///   - prefix: Prefix to remove (e.g., "bg-", "text-")
    /// - Returns: CSS color value, or nil if invalid
    private static func parseColor(from className: String, prefix: String) -> String? {
        let colorPart = className.replacingOccurrences(of: prefix, with: "")

        // Simple color mapping (would need comprehensive color palette)
        let colors: [String: String] = [
            "blue-500": "rgb(59 130 246)",
            "blue-600": "rgb(37 99 235)",
            "gray-900": "rgb(17 24 39)",
            "gray-950": "rgb(3 7 18)",
            "white": "rgb(255 255 255)",
            // Add more colors as needed
        ]

        return colors[colorPart]
    }

    /// Parses spacing values from a utility class.
    ///
    /// - Parameter className: Full class name
    /// - Returns: CSS spacing properties, or nil if invalid
    private static func parseSpacing(from className: String) -> String? {
        // Check for auto margins
        if className.hasSuffix("-auto") {
            let prefix = String(className.dropLast(5)) // Remove "-auto"
            switch prefix {
            case "m": return "margin: auto;"
            case "mx": return "margin-left: auto; margin-right: auto;"
            case "my": return "margin-top: auto; margin-bottom: auto;"
            case "mt": return "margin-top: auto;"
            case "mr": return "margin-right: auto;"
            case "mb": return "margin-bottom: auto;"
            case "ml": return "margin-left: auto;"
            default: return nil
            }
        }

        // Check for arbitrary values like mb-[-50%]
        if className.contains("[") && className.contains("]") {
            guard let startIndex = className.firstIndex(of: "["),
                  let endIndex = className.firstIndex(of: "]") else {
                return nil
            }

            let prefix = String(className[..<startIndex]).dropLast() // Remove trailing "-"
            let value = String(className[className.index(after: startIndex)..<endIndex])

            switch prefix {
            case "p": return "padding: \(value);"
            case "px": return "padding-left: \(value); padding-right: \(value);"
            case "py": return "padding-top: \(value); padding-bottom: \(value);"
            case "pt": return "padding-top: \(value);"
            case "pr": return "padding-right: \(value);"
            case "pb": return "padding-bottom: \(value);"
            case "pl": return "padding-left: \(value);"
            case "m": return "margin: \(value);"
            case "mx": return "margin-left: \(value); margin-right: \(value);"
            case "my": return "margin-top: \(value); margin-bottom: \(value);"
            case "mt": return "margin-top: \(value);"
            case "mr": return "margin-right: \(value);"
            case "mb": return "margin-bottom: \(value);"
            case "ml": return "margin-left: \(value);"
            default: return nil
            }
        }

        // Extract spacing value
        let parts = className.split(separator: "-")
        guard parts.count >= 2, let value = Int(parts.last!) else {
            return nil
        }

        let spacing = spacingValue(for: value)

        // Determine spacing type
        let prefix = String(parts.first!)
        switch prefix {
        case "p": return "padding: \(spacing);"
        case "px": return "padding-left: \(spacing); padding-right: \(spacing);"
        case "py": return "padding-top: \(spacing); padding-bottom: \(spacing);"
        case "pt": return "padding-top: \(spacing);"
        case "pr": return "padding-right: \(spacing);"
        case "pb": return "padding-bottom: \(spacing);"
        case "pl": return "padding-left: \(spacing);"
        case "m": return "margin: \(spacing);"
        case "mx": return "margin-left: \(spacing); margin-right: \(spacing);"
        case "my": return "margin-top: \(spacing); margin-bottom: \(spacing);"
        case "mt": return "margin-top: \(spacing);"
        case "mr": return "margin-right: \(spacing);"
        case "mb": return "margin-bottom: \(spacing);"
        case "ml": return "margin-left: \(spacing);"
        default: return nil
        }
    }

    /// Converts a spacing scale value to CSS length.
    ///
    /// - Parameter value: Spacing scale value (0-96)
    /// - Returns: CSS length string
    private static func spacingValue(for value: Int) -> String {
        if value == 0 { return "0" }
        return "\(Double(value) * 0.25)rem"
    }

    // MARK: - Additional Parsing Methods

    /// Parses arbitrary value syntax (e.g., bg-[#020617], text-[#F8FAFC])
    private static func parseArbitraryValue(from className: String) -> String? {
        guard let startIndex = className.firstIndex(of: "["),
              let endIndex = className.firstIndex(of: "]") else {
            return nil
        }

        let prefix = String(className[..<startIndex])
        let value = String(className[className.index(after: startIndex)..<endIndex])

        // Background color
        if prefix == "bg-" {
            return "background-color: \(value);"
        }
        // Text color
        if prefix == "text-" {
            return "color: \(value);"
        }
        // Border color
        if prefix == "border-" {
            return "border-color: \(value);"
        }
        // Font family
        if prefix == "font-" {
            return "font-family: \(value);"
        }
        // Max width
        if prefix == "max-w-" {
            return "max-width: \(value);"
        }

        return nil
    }

    /// Parses font size utilities
    private static func parseFontSize(from className: String) -> String? {
        let sizes: [String: String] = [
            "text-xs": "font-size: 0.75rem; line-height: 1rem;",
            "text-sm": "font-size: 0.875rem; line-height: 1.25rem;",
            "text-base": "font-size: 1rem; line-height: 1.5rem;",
            "text-lg": "font-size: 1.125rem; line-height: 1.75rem;",
            "text-xl": "font-size: 1.25rem; line-height: 1.75rem;",
            "text-2xl": "font-size: 1.5rem; line-height: 2rem;",
            "text-3xl": "font-size: 1.875rem; line-height: 2.25rem;",
            "text-4xl": "font-size: 2.25rem; line-height: 2.5rem;",
            "text-5xl": "font-size: 3rem; line-height: 1;",
            "text-6xl": "font-size: 3.75rem; line-height: 1;",
            "text-7xl": "font-size: 4.5rem; line-height: 1;",
            "text-8xl": "font-size: 6rem; line-height: 1;",
            "text-9xl": "font-size: 8rem; line-height: 1;",
        ]
        return sizes[className]
    }

    /// Parses font weight utilities
    private static func parseFontWeight(from className: String) -> String? {
        let weights: [String: String] = [
            "font-thin": "100",
            "font-extralight": "200",
            "font-light": "300",
            "font-normal": "400",
            "font-medium": "500",
            "font-semibold": "600",
            "font-bold": "700",
            "font-extrabold": "800",
            "font-black": "900",
        ]
        return weights[className]
    }

    /// Parses font family utilities
    private static func parseFontFamily(from className: String) -> String? {
        // Font families are typically arbitrary values like font-[system-ui]
        // This is handled by parseArbitraryValue
        return nil
    }

    /// Parses line height utilities
    private static func parseLineHeight(from className: String) -> String? {
        let lineHeights: [String: String] = [
            "leading-tightest": "1",
            "leading-tighter": "1.125",
            "leading-tight": "1.25",
            "leading-snug": "1.375",
            "leading-normal": "1.5",
            "leading-relaxed": "1.625",
            "leading-loose": "2",
            "leading-none": "1",
        ]
        return lineHeights[className]
    }

    /// Parses sizing utilities (width, height, max-width, etc.)
    private static func parseSizing(from className: String, prefix: String) -> String? {
        let sizePart = className.replacingOccurrences(of: prefix, with: "")

        let sizes: [String: String] = [
            "auto": "auto",
            "full": "100%",
            "screen": prefix.contains("h") ? "100vh" : "100vw",
            "min": "min-content",
            "max": "max-content",
            "fit": "fit-content",
        ]

        if let size = sizes[sizePart] {
            return size
        }

        // Fractions (e.g., w-1/2, w-1/3, w-2/3, w-1/4, w-3/4)
        if sizePart.contains("/") {
            let parts = sizePart.split(separator: "/")
            if parts.count == 2, let num = Int(parts[0]), let denom = Int(parts[1]) {
                let percentage = (Double(num) / Double(denom)) * 100
                return String(format: "%.6f%%", percentage)
            }
        }

        // Numeric sizes (e.g., w-64, h-32)
        if let value = Int(sizePart) {
            return "\(Double(value) * 0.25)rem"
        }

        // Container max-width values
        if prefix == "max-w-" {
            let maxWidths: [String: String] = [
                "xs": "20rem",      // 320px
                "sm": "24rem",      // 384px
                "md": "28rem",      // 448px
                "lg": "32rem",      // 512px
                "xl": "36rem",      // 576px
                "2xl": "42rem",     // 672px
                "3xl": "48rem",     // 768px
                "4xl": "56rem",     // 896px
                "5xl": "64rem",     // 1024px
                "6xl": "72rem",     // 1152px
                "7xl": "80rem",     // 1280px
                // Specific pixel values
                "320": "320px",
                "350": "350px",
                "480": "480px",
                "500": "500px",
                "800": "800px",
                "1000": "1000px",
                "1100": "1100px",
                "1280": "1280px",
                "screen": "100vw",
            ]
            return maxWidths[sizePart]
        }

        return nil
    }

    /// Parses z-index utilities
    private static func parseZIndex(from className: String) -> String? {
        let zIndexPart = className.replacingOccurrences(of: "z-", with: "")
        return zIndexPart
    }

    /// Parses border radius utilities
    private static func parseBorderRadius(from className: String) -> String? {
        let radii: [String: String] = [
            "rounded-none": "border-radius: 0;",
            "rounded-sm": "border-radius: 0.125rem;",
            "rounded": "border-radius: 0.25rem;",
            "rounded-md": "border-radius: 0.375rem;",
            "rounded-lg": "border-radius: 0.5rem;",
            "rounded-xl": "border-radius: 0.75rem;",
            "rounded-2xl": "border-radius: 1rem;",
            "rounded-3xl": "border-radius: 1.5rem;",
            "rounded-full": "border-radius: 9999px;",
        ]
        return radii[className]
    }

    /// Parses shadow utilities
    private static func parseShadow(from className: String) -> String? {
        let shadows: [String: String] = [
            "shadow-sm": "box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);",
            "shadow": "box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);",
            "shadow-md": "box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);",
            "shadow-lg": "box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);",
            "shadow-xl": "box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);",
            "shadow-2xl": "box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);",
            "shadow-none": "box-shadow: none;",
        ]
        return shadows[className]
    }

    /// Parses border width utilities
    private static func parseBorderWidth(from className: String) -> String? {
        if className == "border" {
            return "border-width: 1px; border-style: solid;"
        }
        if className == "border-0" {
            return "border-width: 0;"
        }
        if className == "border-2" {
            return "border-width: 2px; border-style: solid;"
        }
        if className == "border-4" {
            return "border-width: 4px; border-style: solid;"
        }
        if className == "border-8" {
            return "border-width: 8px; border-style: solid;"
        }
        return nil
    }

    /// Parses flex justify content utilities
    private static func parseFlexJustify(from className: String) -> String? {
        let justifies: [String: String] = [
            "justify-start": "flex-start",
            "justify-end": "flex-end",
            "justify-center": "center",
            "justify-between": "space-between",
            "justify-around": "space-around",
            "justify-evenly": "space-evenly",
        ]
        return justifies[className]
    }

    /// Parses flex align items utilities
    private static func parseFlexAlign(from className: String) -> String? {
        let aligns: [String: String] = [
            "items-start": "flex-start",
            "items-end": "flex-end",
            "items-center": "center",
            "items-baseline": "baseline",
            "items-stretch": "stretch",
        ]
        return aligns[className]
    }

    /// Parses grid columns utilities
    private static func parseGridCols(from className: String) -> String? {
        let colsPart = className.replacingOccurrences(of: "grid-cols-", with: "")
        return colsPart
    }

    /// Parses gap utilities
    private static func parseGap(from className: String) -> String? {
        let gapPart = className.replacingOccurrences(of: "gap-", with: "")
        if let value = Int(gapPart) {
            return "\(Double(value) * 0.25)rem"
        }
        return nil
    }

    /// Parses transition utilities
    private static func parseTransition(from className: String) -> String? {
        let transitions: [String: String] = [
            "transition-none": "transition-property: none;",
            "transition-all": "transition-property: all; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-duration: 150ms;",
            "transition": "transition-property: color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-duration: 150ms;",
            "transition-colors": "transition-property: color, background-color, border-color, text-decoration-color, fill, stroke; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-duration: 150ms;",
            "transition-opacity": "transition-property: opacity; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-duration: 150ms;",
            "transition-shadow": "transition-property: box-shadow; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-duration: 150ms;",
            "transition-transform": "transition-property: transform; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-duration: 150ms;",
        ]
        return transitions[className]
    }

    /// Parses duration utilities
    private static func parseDuration(from className: String) -> String? {
        let durationPart = className.replacingOccurrences(of: "duration-", with: "")
        return "\(durationPart)ms"
    }

    /// Parses easing utilities
    private static func parseEasing(from className: String) -> String? {
        let easings: [String: String] = [
            "ease-linear": "linear",
            "ease-in": "cubic-bezier(0.4, 0, 1, 1)",
            "ease-out": "cubic-bezier(0, 0, 0.2, 1)",
            "ease-in-out": "cubic-bezier(0.4, 0, 0.2, 1)",
        ]
        return easings[className]
    }

    /// Parses rotation utilities
    private static func parseRotation(from className: String) -> String? {
        let rotatePart = className.replacingOccurrences(of: "rotate-", with: "")
        return "\(rotatePart)deg"
    }

    /// Parses opacity utilities
    private static func parseOpacity(from className: String) -> String? {
        let opacityPart = className.replacingOccurrences(of: "opacity-", with: "")
        if let value = Int(opacityPart) {
            return "\(Double(value) / 100)"
        }
        return nil
    }

    /// Parses vertical align utilities
    private static func parseVerticalAlign(from className: String) -> String? {
        let aligns: [String: String] = [
            "align-baseline": "baseline",
            "align-top": "top",
            "align-middle": "middle",
            "align-bottom": "bottom",
            "align-text-top": "text-top",
            "align-text-bottom": "text-bottom",
        ]
        return aligns[className]
    }

    /// Parses grid rows utilities
    private static func parseGridRows(from className: String) -> String? {
        let rowsPart = className.replacingOccurrences(of: "grid-rows-", with: "")
        return rowsPart
    }

    /// Parses grid span utilities
    private static func parseGridSpan(from className: String, prefix: String) -> String? {
        let spanPart = className.replacingOccurrences(of: prefix, with: "")
        return spanPart
    }

    /// Parses grid start utilities
    private static func parseGridStart(from className: String, prefix: String) -> String? {
        let startPart = className.replacingOccurrences(of: prefix, with: "")
        return startPart
    }

    /// Parses grid flow utilities
    private static func parseGridFlow(from className: String) -> String? {
        let flows: [String: String] = [
            "grid-flow-row": "row",
            "grid-flow-col": "column",
            "grid-flow-row-dense": "row dense",
            "grid-flow-col-dense": "column dense",
        ]
        return flows[className]
    }

    /// Parses inset position utilities
    private static func parseInset(from className: String) -> String? {
        // Extract position and value
        let parts = className.split(separator: "-")
        guard parts.count >= 2 else { return nil }

        let position = String(parts[0])
        let valuePart = String(parts[1...].joined(separator: "-"))

        // Handle numeric values
        if let value = Int(valuePart) {
            let spacing = spacingValue(for: value)
            switch position {
            case "top": return "top: \(spacing);"
            case "right": return "right: \(spacing);"
            case "bottom": return "bottom: \(spacing);"
            case "left": return "left: \(spacing);"
            case "inset":
                if parts.count >= 3, parts[1] == "x" {
                    return "left: \(spacing); right: \(spacing);"
                } else if parts.count >= 3, parts[1] == "y" {
                    return "top: \(spacing); bottom: \(spacing);"
                }
            default: break
            }
        }

        // Handle special keywords
        switch valuePart {
        case "0":
            switch position {
            case "top": return "top: 0;"
            case "right": return "right: 0;"
            case "bottom": return "bottom: 0;"
            case "left": return "left: 0;"
            default: break
            }
        case "auto":
            switch position {
            case "top": return "top: auto;"
            case "right": return "right: auto;"
            case "bottom": return "bottom: auto;"
            case "left": return "left: auto;"
            default: break
            }
        case "full":
            switch position {
            case "top": return "top: 100%;"
            case "right": return "right: 100%;"
            case "bottom": return "bottom: 100%;"
            case "left": return "left: 100%;"
            default: break
            }
        default: break
        }

        return nil
    }

    /// Parses tracking (letter-spacing) utilities
    private static func parseTracking(from className: String) -> String? {
        let trackings: [String: String] = [
            "tracking-tighter": "-0.05em",
            "tracking-tight": "-0.025em",
            "tracking-normal": "0",
            "tracking-wide": "0.025em",
            "tracking-wider": "0.05em",
            "tracking-widest": "0.1em",
        ]
        return trackings[className]
    }
}

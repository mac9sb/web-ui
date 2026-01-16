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

        switch true {
        case selector.starts(with: "space-"):
            return ".\(selector) > * + * { \(properties) }"
        default:
            return ".\(selector) { \(properties) }"
        }
    }

    /// Builds a CSS selector with modifiers.
    ///
    /// - Parameters:
    ///   - baseClass: The base class name
    ///   - modifiers: Array of modifier strings
    /// - Returns: Escaped selector string
    private static func buildSelector(for baseClass: String, modifiers: [String]) -> String {
        var selector =
            baseClass
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
                case "group-hover": selector = "group:hover .\(selector)"
                case "group-focus": selector = "group:focus .\(selector)"
                case "peer-hover": selector = "peer:hover ~ .\(selector)"
                case "peer-focus": selector = "peer:focus ~ .\(selector)"
                case "peer-checked": selector = "peer:checked ~ .\(selector)"
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

        // Align content (for grid/flexbox)
        if baseClass == "content-start" { return "align-content: flex-start;" }
        if baseClass == "content-end" { return "align-content: flex-end;" }
        if baseClass == "content-center" { return "align-content: center;" }
        if baseClass == "content-between" { return "align-content: space-between;" }
        if baseClass == "content-around" { return "align-content: space-around;" }
        if baseClass == "content-evenly" { return "align-content: space-evenly;" }

        // Space between (gap for flex/grid children)
        if baseClass.hasPrefix("space-x-") {
            if let space = parseSpaceBetween(from: baseClass, axis: "x") {
                return space
            }
        }
        if baseClass.hasPrefix("space-y-") {
            if let space = parseSpaceBetween(from: baseClass, axis: "y") {
                return space
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
        if baseClass.hasPrefix("top-") || baseClass.hasPrefix("left-") || baseClass.hasPrefix("right-") || baseClass.hasPrefix("bottom-") || baseClass.hasPrefix("inset-x-")
            || baseClass.hasPrefix("inset-y-")
        {
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
        if baseClass.hasPrefix("p-") || baseClass.hasPrefix("px-") || baseClass.hasPrefix("py-") || baseClass.hasPrefix("pt-") || baseClass.hasPrefix("pr-")
            || baseClass.hasPrefix("pb-") || baseClass.hasPrefix("pl-")
        {
            if let spacing = parseSpacing(from: baseClass) {
                return spacing
            }
        }

        // Margin
        if baseClass.hasPrefix("m-") || baseClass.hasPrefix("mx-") || baseClass.hasPrefix("my-") || baseClass.hasPrefix("mt-") || baseClass.hasPrefix("mr-")
            || baseClass.hasPrefix("mb-") || baseClass.hasPrefix("ml-")
        {
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
        
        // Casing
        if baseClass == "uppercase" { return "text-transform: uppercase;" }
        if baseClass == "lowerase" { return "text-transform: lowercase;" }
        if baseClass == "capitalize" { return "text-transform: capitalize;" }
        if baseClass == "normal-case" { return "text-transform: none;" }

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

        // Border colors (not edge-specific like border-t-, border-b-, etc.)
        if baseClass.hasPrefix("border-") && !baseClass.hasPrefix("border-t-") && !baseClass.hasPrefix("border-b-") && !baseClass.hasPrefix("border-l-")
            && !baseClass.hasPrefix("border-r-") && !baseClass.hasPrefix("border-x-") && !baseClass.hasPrefix("border-y-") && baseClass != "border-t" && baseClass != "border-b"
            && baseClass != "border-l" && baseClass != "border-r" && baseClass != "border-x" && baseClass != "border-y"
        {
            // Check for border width first
            if let borderWidth = parseBorderWidth(from: baseClass) {
                return borderWidth
            }
            // Then check for border color
            if let color = parseColor(from: baseClass, prefix: "border-") {
                return "border-color: \(color);"
            }
        }

        // Border sides (basic)
        if baseClass == "border-t" { return "border-top-width: 1px; border-top-style: solid;" }
        if baseClass == "border-b" { return "border-bottom-width: 1px; border-bottom-style: solid;" }
        if baseClass == "border-l" { return "border-left-width: 1px; border-left-style: solid;" }
        if baseClass == "border-r" { return "border-right-width: 1px; border-right-style: solid;" }
        if baseClass == "border-x" { return "border-left-width: 1px; border-left-style: solid; border-right-width: 1px; border-right-style: solid;" }
        if baseClass == "border-y" { return "border-top-width: 1px; border-top-style: solid; border-bottom-width: 1px; border-bottom-style: solid;" }
        if baseClass == "border" { return "border-width: 1px; border-style: solid;" }

        // Border sides with widths (e.g., border-b-1, border-x-2)
        if let borderSide = parseBorderSide(from: baseClass) {
            return borderSide
        }

        // Border sides with colors (e.g., border-b-black, border-t-zinc-800)
        if let borderSideColor = parseBorderSideColor(from: baseClass) {
            return borderSideColor
        }

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

        // Filter utilities
        if baseClass == "invert" { return "filter: invert(100%);" }
        if baseClass == "invert-0" { return "filter: invert(0);" }
        if baseClass.hasPrefix("invert-") {
            let value = String(baseClass.dropFirst(7))
            if let amount = Int(value) {
                return "filter: invert(\(amount)%);"
            }
        }
        if baseClass == "grayscale" { return "filter: grayscale(100%);" }
        if baseClass == "grayscale-0" { return "filter: grayscale(0);" }
        if baseClass.hasPrefix("brightness-") {
            let value = String(baseClass.dropFirst(11))
            if let amount = Int(value) {
                return "filter: brightness(\(Double(amount) / 100));"
            }
        }
        if baseClass.hasPrefix("contrast-") {
            let value = String(baseClass.dropFirst(9))
            if let amount = Int(value) {
                return "filter: contrast(\(Double(amount) / 100));"
            }
        }
        if baseClass.hasPrefix("blur-") {
            if let blur = parseBlur(from: baseClass) {
                return "filter: blur(\(blur));"
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

        // Complete Tailwind CSS color palette
        let colors: [String: String] = [
            // White and Black
            "white": "rgb(255 255 255)",
            "black": "rgb(0 0 0)",

            // Slate
            "slate-50": "rgb(248 250 252)",
            "slate-100": "rgb(241 245 249)",
            "slate-200": "rgb(226 232 240)",
            "slate-300": "rgb(203 213 225)",
            "slate-400": "rgb(148 163 184)",
            "slate-500": "rgb(100 116 139)",
            "slate-600": "rgb(71 85 105)",
            "slate-700": "rgb(51 65 85)",
            "slate-800": "rgb(30 41 59)",
            "slate-900": "rgb(15 23 42)",
            "slate-950": "rgb(2 6 23)",

            // Gray
            "gray-50": "rgb(249 250 251)",
            "gray-100": "rgb(243 244 246)",
            "gray-200": "rgb(229 231 235)",
            "gray-300": "rgb(209 213 219)",
            "gray-400": "rgb(156 163 175)",
            "gray-500": "rgb(107 114 128)",
            "gray-600": "rgb(75 85 99)",
            "gray-700": "rgb(55 65 81)",
            "gray-800": "rgb(31 41 55)",
            "gray-900": "rgb(17 24 39)",
            "gray-950": "rgb(3 7 18)",

            // Zinc
            "zinc-50": "rgb(250 250 250)",
            "zinc-100": "rgb(244 244 245)",
            "zinc-200": "rgb(228 228 231)",
            "zinc-300": "rgb(212 212 216)",
            "zinc-400": "rgb(161 161 170)",
            "zinc-500": "rgb(113 113 122)",
            "zinc-600": "rgb(82 82 91)",
            "zinc-700": "rgb(63 63 70)",
            "zinc-800": "rgb(39 39 42)",
            "zinc-900": "rgb(24 24 27)",
            "zinc-950": "rgb(9 9 11)",

            // Neutral
            "neutral-50": "rgb(250 250 250)",
            "neutral-100": "rgb(245 245 245)",
            "neutral-200": "rgb(229 229 229)",
            "neutral-300": "rgb(212 212 212)",
            "neutral-400": "rgb(163 163 163)",
            "neutral-500": "rgb(115 115 115)",
            "neutral-600": "rgb(82 82 82)",
            "neutral-700": "rgb(64 64 64)",
            "neutral-800": "rgb(38 38 38)",
            "neutral-900": "rgb(23 23 23)",
            "neutral-950": "rgb(10 10 10)",

            // Stone
            "stone-50": "rgb(250 250 249)",
            "stone-100": "rgb(245 245 244)",
            "stone-200": "rgb(231 229 228)",
            "stone-300": "rgb(214 211 209)",
            "stone-400": "rgb(168 162 158)",
            "stone-500": "rgb(120 113 108)",
            "stone-600": "rgb(87 83 78)",
            "stone-700": "rgb(68 64 60)",
            "stone-800": "rgb(41 37 36)",
            "stone-900": "rgb(28 25 23)",
            "stone-950": "rgb(12 10 9)",

            // Red
            "red-50": "rgb(254 242 242)",
            "red-100": "rgb(254 226 226)",
            "red-200": "rgb(254 202 202)",
            "red-300": "rgb(252 165 165)",
            "red-400": "rgb(248 113 113)",
            "red-500": "rgb(239 68 68)",
            "red-600": "rgb(220 38 38)",
            "red-700": "rgb(185 28 28)",
            "red-800": "rgb(153 27 27)",
            "red-900": "rgb(127 29 29)",
            "red-950": "rgb(69 10 10)",

            // Orange
            "orange-50": "rgb(255 247 237)",
            "orange-100": "rgb(255 237 213)",
            "orange-200": "rgb(254 215 170)",
            "orange-300": "rgb(253 186 116)",
            "orange-400": "rgb(251 146 60)",
            "orange-500": "rgb(249 115 22)",
            "orange-600": "rgb(234 88 12)",
            "orange-700": "rgb(194 65 12)",
            "orange-800": "rgb(154 52 18)",
            "orange-900": "rgb(124 45 18)",
            "orange-950": "rgb(67 20 7)",

            // Amber
            "amber-50": "rgb(255 251 235)",
            "amber-100": "rgb(254 243 199)",
            "amber-200": "rgb(253 230 138)",
            "amber-300": "rgb(252 211 77)",
            "amber-400": "rgb(251 191 36)",
            "amber-500": "rgb(245 158 11)",
            "amber-600": "rgb(217 119 6)",
            "amber-700": "rgb(180 83 9)",
            "amber-800": "rgb(146 64 14)",
            "amber-900": "rgb(120 53 15)",
            "amber-950": "rgb(69 26 3)",

            // Yellow
            "yellow-50": "rgb(254 252 232)",
            "yellow-100": "rgb(254 249 195)",
            "yellow-200": "rgb(254 240 138)",
            "yellow-300": "rgb(253 224 71)",
            "yellow-400": "rgb(250 204 21)",
            "yellow-500": "rgb(234 179 8)",
            "yellow-600": "rgb(202 138 4)",
            "yellow-700": "rgb(161 98 7)",
            "yellow-800": "rgb(133 77 14)",
            "yellow-900": "rgb(113 63 18)",
            "yellow-950": "rgb(66 32 6)",

            // Lime
            "lime-50": "rgb(247 254 231)",
            "lime-100": "rgb(236 252 203)",
            "lime-200": "rgb(217 249 157)",
            "lime-300": "rgb(190 242 100)",
            "lime-400": "rgb(163 230 53)",
            "lime-500": "rgb(132 204 22)",
            "lime-600": "rgb(101 163 13)",
            "lime-700": "rgb(77 124 15)",
            "lime-800": "rgb(63 98 18)",
            "lime-900": "rgb(54 83 20)",
            "lime-950": "rgb(26 46 5)",

            // Green
            "green-50": "rgb(240 253 244)",
            "green-100": "rgb(220 252 231)",
            "green-200": "rgb(187 247 208)",
            "green-300": "rgb(134 239 172)",
            "green-400": "rgb(74 222 128)",
            "green-500": "rgb(34 197 94)",
            "green-600": "rgb(22 163 74)",
            "green-700": "rgb(21 128 61)",
            "green-800": "rgb(22 101 52)",
            "green-900": "rgb(20 83 45)",
            "green-950": "rgb(5 46 22)",

            // Emerald
            "emerald-50": "rgb(236 253 245)",
            "emerald-100": "rgb(209 250 229)",
            "emerald-200": "rgb(167 243 208)",
            "emerald-300": "rgb(110 231 183)",
            "emerald-400": "rgb(52 211 153)",
            "emerald-500": "rgb(16 185 129)",
            "emerald-600": "rgb(5 150 105)",
            "emerald-700": "rgb(4 120 87)",
            "emerald-800": "rgb(6 95 70)",
            "emerald-900": "rgb(6 78 59)",
            "emerald-950": "rgb(2 44 34)",

            // Teal
            "teal-50": "rgb(240 253 250)",
            "teal-100": "rgb(204 251 241)",
            "teal-200": "rgb(153 246 228)",
            "teal-300": "rgb(94 234 212)",
            "teal-400": "rgb(45 212 191)",
            "teal-500": "rgb(20 184 166)",
            "teal-600": "rgb(13 148 136)",
            "teal-700": "rgb(15 118 110)",
            "teal-800": "rgb(17 94 89)",
            "teal-900": "rgb(19 78 74)",
            "teal-950": "rgb(4 47 46)",

            // Cyan
            "cyan-50": "rgb(236 254 255)",
            "cyan-100": "rgb(207 250 254)",
            "cyan-200": "rgb(165 243 252)",
            "cyan-300": "rgb(103 232 249)",
            "cyan-400": "rgb(34 211 238)",
            "cyan-500": "rgb(6 182 212)",
            "cyan-600": "rgb(8 145 178)",
            "cyan-700": "rgb(14 116 144)",
            "cyan-800": "rgb(21 94 117)",
            "cyan-900": "rgb(22 78 99)",
            "cyan-950": "rgb(8 51 68)",

            // Sky
            "sky-50": "rgb(240 249 255)",
            "sky-100": "rgb(224 242 254)",
            "sky-200": "rgb(186 230 253)",
            "sky-300": "rgb(125 211 252)",
            "sky-400": "rgb(56 189 248)",
            "sky-500": "rgb(14 165 233)",
            "sky-600": "rgb(2 132 199)",
            "sky-700": "rgb(3 105 161)",
            "sky-800": "rgb(7 89 133)",
            "sky-900": "rgb(12 74 110)",
            "sky-950": "rgb(8 47 73)",

            // Blue
            "blue-50": "rgb(239 246 255)",
            "blue-100": "rgb(219 234 254)",
            "blue-200": "rgb(191 219 254)",
            "blue-300": "rgb(147 197 253)",
            "blue-400": "rgb(96 165 250)",
            "blue-500": "rgb(59 130 246)",
            "blue-600": "rgb(37 99 235)",
            "blue-700": "rgb(29 78 216)",
            "blue-800": "rgb(30 64 175)",
            "blue-900": "rgb(30 58 138)",
            "blue-950": "rgb(23 37 84)",

            // Indigo
            "indigo-50": "rgb(238 242 255)",
            "indigo-100": "rgb(224 231 255)",
            "indigo-200": "rgb(199 210 254)",
            "indigo-300": "rgb(165 180 252)",
            "indigo-400": "rgb(129 140 248)",
            "indigo-500": "rgb(99 102 241)",
            "indigo-600": "rgb(79 70 229)",
            "indigo-700": "rgb(67 56 202)",
            "indigo-800": "rgb(55 48 163)",
            "indigo-900": "rgb(49 46 129)",
            "indigo-950": "rgb(30 27 75)",

            // Violet
            "violet-50": "rgb(245 243 255)",
            "violet-100": "rgb(237 233 254)",
            "violet-200": "rgb(221 214 254)",
            "violet-300": "rgb(196 181 253)",
            "violet-400": "rgb(167 139 250)",
            "violet-500": "rgb(139 92 246)",
            "violet-600": "rgb(124 58 237)",
            "violet-700": "rgb(109 40 217)",
            "violet-800": "rgb(91 33 182)",
            "violet-900": "rgb(76 29 149)",
            "violet-950": "rgb(46 16 101)",

            // Purple
            "purple-50": "rgb(250 245 255)",
            "purple-100": "rgb(243 232 255)",
            "purple-200": "rgb(233 213 255)",
            "purple-300": "rgb(216 180 254)",
            "purple-400": "rgb(192 132 252)",
            "purple-500": "rgb(168 85 247)",
            "purple-600": "rgb(147 51 234)",
            "purple-700": "rgb(126 34 206)",
            "purple-800": "rgb(107 33 168)",
            "purple-900": "rgb(88 28 135)",
            "purple-950": "rgb(59 7 100)",

            // Fuchsia
            "fuchsia-50": "rgb(253 244 255)",
            "fuchsia-100": "rgb(250 232 255)",
            "fuchsia-200": "rgb(245 208 254)",
            "fuchsia-300": "rgb(240 171 252)",
            "fuchsia-400": "rgb(232 121 249)",
            "fuchsia-500": "rgb(217 70 239)",
            "fuchsia-600": "rgb(192 38 211)",
            "fuchsia-700": "rgb(162 28 175)",
            "fuchsia-800": "rgb(134 25 143)",
            "fuchsia-900": "rgb(112 26 117)",
            "fuchsia-950": "rgb(74 4 78)",

            // Pink
            "pink-50": "rgb(253 242 248)",
            "pink-100": "rgb(252 231 243)",
            "pink-200": "rgb(251 207 232)",
            "pink-300": "rgb(249 168 212)",
            "pink-400": "rgb(244 114 182)",
            "pink-500": "rgb(236 72 153)",
            "pink-600": "rgb(219 39 119)",
            "pink-700": "rgb(190 24 93)",
            "pink-800": "rgb(157 23 77)",
            "pink-900": "rgb(131 24 67)",
            "pink-950": "rgb(80 7 36)",

            // Rose
            "rose-50": "rgb(255 241 242)",
            "rose-100": "rgb(255 228 230)",
            "rose-200": "rgb(254 205 211)",
            "rose-300": "rgb(253 164 175)",
            "rose-400": "rgb(251 113 133)",
            "rose-500": "rgb(244 63 94)",
            "rose-600": "rgb(225 29 72)",
            "rose-700": "rgb(190 18 60)",
            "rose-800": "rgb(159 18 57)",
            "rose-900": "rgb(136 19 55)",
            "rose-950": "rgb(76 5 25)",

            // Transparent
            "transparent": "transparent",
            "current": "currentColor",
            "inherit": "inherit",
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
            let prefix = String(className.dropLast(5))  // Remove "-auto"
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
                let endIndex = className.firstIndex(of: "]")
            else {
                return nil
            }

            let prefix = String(className[..<startIndex]).dropLast()  // Remove trailing "-"
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
            let endIndex = className.firstIndex(of: "]")
        else {
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
            "text-xs2": "font-size: 0.65rem; line-height: 1rem;",
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
        nil
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

        // Handle arbitrary values like [220px], [3.5rem], [100dvh]
        if sizePart.hasPrefix("[") && sizePart.hasSuffix("]") {
            let value = String(sizePart.dropFirst().dropLast())
            return value
        }

        let sizes: [String: String] = [
            "auto": "auto",
            "full": "100%",
            "screen": prefix.contains("h") ? "100vh" : "100vw",
            "dvh": "100dvh",
            "svh": "100svh",
            "lvh": "100lvh",
            "min": "min-content",
            "max": "max-content",
            "fit": "fit-content",
            "px": "1px",
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
                "xs": "20rem",  // 320px
                "sm": "24rem",  // 384px
                "md": "28rem",  // 448px
                "lg": "32rem",  // 512px
                "xl": "36rem",  // 576px
                "2xl": "42rem",  // 672px
                "3xl": "48rem",  // 768px
                "4xl": "56rem",  // 896px
                "5xl": "64rem",  // 1024px
                "6xl": "72rem",  // 1152px
                "7xl": "80rem",  // 1280px
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

        // Min height presets
        if prefix == "min-h-" {
            let minHeights: [String: String] = [
                "0": "0px",
                "screen": "100vh",
                "dvh": "100dvh",
                "svh": "100svh",
                "lvh": "100lvh",
            ]
            if let height = minHeights[sizePart] {
                return height
            }
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
        if className == "border-1" {
            return "border-width: 1px; border-style: solid;"
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
            "transition":
                "transition-property: color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-duration: 150ms;",
            "transition-colors":
                "transition-property: color, background-color, border-color, text-decoration-color, fill, stroke; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-duration: 150ms;",
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

    /// Parses blur utilities
    private static func parseBlur(from className: String) -> String? {
        let blurPart = className.replacingOccurrences(of: "blur-", with: "")
        let blurs: [String: String] = [
            "none": "0",
            "sm": "4px",
            "": "8px",
            "md": "12px",
            "lg": "16px",
            "xl": "24px",
            "2xl": "40px",
            "3xl": "64px",
        ]
        return blurs[blurPart]
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

    /// Parses border side utilities with widths (e.g., border-b-1, border-x-2)
    private static func parseBorderSide(from className: String) -> String? {
        // Match patterns like border-b-1, border-t-2, border-x-4, border-y-8
        let sideWidthPatterns: [(prefix: String, cssProperty: String)] = [
            ("border-t-", "border-top"),
            ("border-b-", "border-bottom"),
            ("border-l-", "border-left"),
            ("border-r-", "border-right"),
        ]

        for (prefix, cssProperty) in sideWidthPatterns {
            if className.hasPrefix(prefix) {
                let widthPart = className.replacingOccurrences(of: prefix, with: "")
                // Check if it's a number (width value)
                if let width = Int(widthPart) {
                    let pixelWidth = width == 1 ? "1px" : "\(width)px"
                    return "\(cssProperty)-width: \(pixelWidth); \(cssProperty)-style: solid;"
                }
            }
        }

        // Handle border-x and border-y with widths
        if className.hasPrefix("border-x-") {
            let widthPart = className.replacingOccurrences(of: "border-x-", with: "")
            if let width = Int(widthPart) {
                let pixelWidth = width == 1 ? "1px" : "\(width)px"
                return "border-left-width: \(pixelWidth); border-left-style: solid; border-right-width: \(pixelWidth); border-right-style: solid;"
            }
        }

        if className.hasPrefix("border-y-") {
            let widthPart = className.replacingOccurrences(of: "border-y-", with: "")
            if let width = Int(widthPart) {
                let pixelWidth = width == 1 ? "1px" : "\(width)px"
                return "border-top-width: \(pixelWidth); border-top-style: solid; border-bottom-width: \(pixelWidth); border-bottom-style: solid;"
            }
        }

        return nil
    }

    /// Parses space between utilities (e.g., space-y-4, space-x-2)
    /// Uses CSS custom property to set the spacing value
    private static func parseSpaceBetween(from className: String, axis: String) -> String? {
        let prefix = "space-\(axis)-"
        let valuePart = className.replacingOccurrences(of: prefix, with: "")

        if let value = Int(valuePart) {
            let spacing = "\(Double(value) * 0.25)rem"
            guard axis == "y" else {
                return "--space-x-reverse: 0; margin-left: calc(\(spacing) * calc(1 - var(--space-x-reverse))); margin-right: calc(\(spacing) * var(--space-x-reverse));"
            }
            return "--space-y-reverse: 0; margin-top: calc(\(spacing) * calc(1 - var(--space-y-reverse))); margin-bottom: calc(\(spacing) * var(--space-y-reverse));"
        }

        return nil
    }

    /// Parses border side color utilities (e.g., border-b-black, border-t-zinc-800)
    private static func parseBorderSideColor(from className: String) -> String? {
        let sidePrefixes: [(prefix: String, cssProperty: String)] = [
            ("border-t-", "border-top-color"),
            ("border-b-", "border-bottom-color"),
            ("border-l-", "border-left-color"),
            ("border-r-", "border-right-color"),
            ("border-x-", "border-left-color: {0}; border-right-color"),
            ("border-y-", "border-top-color: {0}; border-bottom-color"),
        ]

        for (prefix, cssProperty) in sidePrefixes {
            if className.hasPrefix(prefix) {
                let colorPart = className.replacingOccurrences(of: prefix, with: "")
                // Skip if it's a number (that's a width, not a color)
                if Int(colorPart) != nil {
                    continue
                }
                // Try to parse as color
                if let color = parseColor(from: "border-\(colorPart)", prefix: "border-") {
                    if cssProperty.contains("{0}") {
                        // For x/y borders, we need to set both sides
                        return cssProperty.replacingOccurrences(of: "{0}", with: color) + ": \(color);"
                    }
                    return "\(cssProperty): \(color);"
                }
            }
        }

        return nil
    }
}

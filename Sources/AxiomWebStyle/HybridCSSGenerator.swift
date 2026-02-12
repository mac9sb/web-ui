import Foundation
import AxiomWebUI

public struct GeneratedCSS: Sendable, Equatable {
    public let content: String
    public let classes: [String]

    public init(content: String, classes: [String]) {
        self.content = content
        self.classes = classes
    }
}

public enum HybridCSSGenerator {
    public static func extractClasses(from nodes: [HTMLNode]) -> [String] {
        var classes: Set<String> = []

        func traverse(_ node: HTMLNode) {
            switch node {
            case .text:
                return
            case .element(let element):
                for attr in element.attributes where attr.name == "class" {
                    let values = (attr.value ?? "").split(whereSeparator: \.isWhitespace).map(String.init)
                    values.forEach { classes.insert($0) }
                }
                for child in element.children {
                    traverse(child)
                }
            }
        }

        for node in nodes {
            traverse(node)
        }

        return classes.sorted()
    }

    public static func generate(classes: [String]) -> GeneratedCSS {
        var baseRules: [String] = []
        var utilityRules: [String] = []
        var mediaRules: [String: [String]] = [:]

        baseRules.append("*{box-sizing:border-box}")
        baseRules.append("html,body{margin:0;padding:0}")

        for className in classes.sorted() {
            let parts = className.split(separator: ":").map(String.init)
            let baseClass = parts.last ?? className
            let modifiers = Array(parts.dropLast())

            guard let declarations = declarations(for: baseClass) else {
                continue
            }

            let selector = ".\(escapeSelector(className))\(pseudoSelector(modifiers: modifiers))"
            let rule = "\(selector){\(declarations)}"

            if let media = mediaQuery(for: modifiers) {
                mediaRules[media, default: []].append(rule)
            } else {
                utilityRules.append(rule)
            }
        }

        var css = "@layer reset{\(baseRules.joined(separator: ""))}"
        css += "@layer tokens{:root{--space-unit:0.25rem;--font-base:1rem;--shadow-xl2:0 20px 25px -5px rgb(0 0 0 / 0.2)}}"
        css += "@layer components{}"
        css += "@layer utilities{\(utilityRules.joined(separator: ""))}"

        for key in mediaRules.keys.sorted() {
            let rules = mediaRules[key, default: []].joined(separator: "")
            css += "\(key){@layer states{\(rules)}}"
        }

        return GeneratedCSS(content: css, classes: classes.sorted())
    }

    private static func declarations(for baseClass: String) -> String? {
        if baseClass == "flex" { return "display:flex" }
        if baseClass == "flex-col" { return "flex-direction:column" }
        if baseClass == "flex-row" { return "flex-direction:row" }
        if baseClass == "items-center" { return "align-items:center" }
        if baseClass == "items-start" { return "align-items:flex-start" }
        if baseClass == "items-end" { return "align-items:flex-end" }
        if baseClass == "grow" || baseClass == "grow-1" { return "flex-grow:1" }
        if baseClass == "relative" { return "position:relative" }
        if baseClass == "absolute" { return "position:absolute" }
        if baseClass == "fixed" { return "position:fixed" }
        if baseClass == "sticky" { return "position:sticky" }
        if baseClass == "w-full" { return "width:100%" }
        if baseClass == "min-h-dvh" { return "min-height:100dvh" }
        if baseClass == "font-bold" { return "font-weight:700" }
        if baseClass == "font-semibold" { return "font-weight:600" }
        if baseClass == "font-medium" { return "font-weight:500" }
        if baseClass == "font-normal" { return "font-weight:400" }
        if baseClass == "text-sm" { return "font-size:0.875rem" }
        if baseClass == "text-base" { return "font-size:1rem" }
        if baseClass == "text-lg" { return "font-size:1.125rem" }
        if baseClass == "text-xl" { return "font-size:1.25rem" }
        if baseClass == "text-2xl" { return "font-size:1.5rem" }
        if baseClass == "text-3xl" { return "font-size:1.875rem" }
        if baseClass == "border-1" { return "border-width:1px;border-style:solid" }
        if baseClass == "shadow-xl2" { return "box-shadow:var(--shadow-xl2)" }

        if let spacing = parseSpacing(baseClass, prefix: "p") {
            return spacing
        }
        if let spacing = parseSpacing(baseClass, prefix: "m") {
            return spacing
        }

        if baseClass.hasPrefix("z-"), let value = Int(baseClass.dropFirst(2)) {
            return "z-index:\(value)"
        }

        if baseClass.hasPrefix("bg-") {
            let token = String(baseClass.dropFirst(3))
            if let value = colorValue(token) {
                return "background-color:\(value)"
            }
        }

        if baseClass.hasPrefix("text-") {
            let token = String(baseClass.dropFirst(5))
            if let value = colorValue(token) {
                return "color:\(value)"
            }
        }

        if baseClass.hasPrefix("border-") {
            let token = String(baseClass.dropFirst(7))
            if let value = colorValue(token) {
                return "border-color:\(value)"
            }
        }

        return nil
    }

    private static func parseSpacing(_ className: String, prefix: String) -> String? {
        let patterns: [(String, String)] = [
            ("\(prefix)-", prefix == "p" ? "padding" : "margin"),
            ("\(prefix)x-", prefix == "p" ? "padding-inline" : "margin-inline"),
            ("\(prefix)y-", prefix == "p" ? "padding-block" : "margin-block"),
            ("\(prefix)t-", prefix == "p" ? "padding-top" : "margin-top"),
            ("\(prefix)r-", prefix == "p" ? "padding-right" : "margin-right"),
            ("\(prefix)b-", prefix == "p" ? "padding-bottom" : "margin-bottom"),
            ("\(prefix)l-", prefix == "p" ? "padding-left" : "margin-left"),
        ]

        for pattern in patterns where className.hasPrefix(pattern.0) {
            let valueToken = className.dropFirst(pattern.0.count)
            guard let value = Double(valueToken) else { return nil }
            return "\(pattern.1):\(value * 0.25)rem"
        }

        return nil
    }

    private static func colorValue(_ token: String) -> String? {
        let baseColors: [String: String] = [
            "black": "#000000",
            "white": "#ffffff",
            "transparent": "transparent",
            "current": "currentColor",
            "inherit": "inherit",
        ]
        if let base = baseColors[token] {
            return base
        }
        if let custom = ColorRegistry.value(for: token) {
            return custom
        }

        let parts = token.split(separator: "-", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return nil }
        let family = parts[0]
        guard let shade = Int(parts[1]) else { return nil }
        guard [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950].contains(shade) else {
            return nil
        }

        let hueAndSaturation: [String: (h: Int, s: Int)] = [
            "slate": (220, 15),
            "gray": (220, 10),
            "zinc": (240, 8),
            "neutral": (0, 8),
            "stone": (30, 10),
            "red": (0, 85),
            "orange": (25, 85),
            "amber": (38, 90),
            "yellow": (52, 90),
            "lime": (84, 80),
            "green": (142, 70),
            "emerald": (160, 70),
            "teal": (175, 65),
            "cyan": (190, 75),
            "sky": (205, 80),
            "blue": (220, 82),
            "indigo": (238, 75),
            "violet": (258, 78),
            "purple": (272, 78),
            "fuchsia": (300, 80),
            "pink": (330, 82),
            "rose": (350, 82),
        ]
        guard let (hue, baseSaturation) = hueAndSaturation[family] else {
            return nil
        }

        let lightnessByShade: [Int: Int] = [
            50: 98,
            100: 95,
            200: 90,
            300: 82,
            400: 70,
            500: 56,
            600: 47,
            700: 38,
            800: 30,
            900: 22,
            950: 14,
        ]
        guard let lightness = lightnessByShade[shade] else {
            return nil
        }

        let saturationAdjustmentByShade: [Int: Int] = [
            50: -14,
            100: -10,
            200: -6,
            300: -2,
            400: 2,
            500: 6,
            600: 2,
            700: -2,
            800: -6,
            900: -10,
            950: -14,
        ]
        let saturation = max(4, min(95, baseSaturation + (saturationAdjustmentByShade[shade] ?? 0)))
        return "hsl(\(hue) \(saturation)% \(lightness)%)"
    }

    private static func escapeSelector(_ value: String) -> String {
        value
            .replacingOccurrences(of: ":", with: "\\:")
            .replacingOccurrences(of: "[", with: "\\[")
            .replacingOccurrences(of: "]", with: "\\]")
    }

    private static func pseudoSelector(modifiers: [String]) -> String {
        if modifiers.contains("hover") {
            return ":hover"
        }
        return ""
    }

    private static func mediaQuery(for modifiers: [String]) -> String? {
        if modifiers.contains("dark") {
            return "@media (prefers-color-scheme: dark)"
        }
        if modifiers.contains("sm") {
            return "@media (min-width: 640px)"
        }
        if modifiers.contains("md") {
            return "@media (min-width: 768px)"
        }
        if modifiers.contains("lg") {
            return "@media (min-width: 1024px)"
        }
        return nil
    }
}

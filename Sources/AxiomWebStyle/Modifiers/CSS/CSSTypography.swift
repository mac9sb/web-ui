import Foundation
import AxiomWebUI

public extension CSSProperty {
    static let direction: CSSProperty = "direction"
    static let font: CSSProperty = "font"
    static let fontFamily: CSSProperty = "font-family"
    static let fontFeatureSettings: CSSProperty = "font-feature-settings"
    static let fontKerning: CSSProperty = "font-kerning"
    static let fontOpticalSizing: CSSProperty = "font-optical-sizing"
    static let fontSize: CSSProperty = "font-size"
    static let fontSizeAdjust: CSSProperty = "font-size-adjust"
    static let fontStretch: CSSProperty = "font-stretch"
    static let fontStyle: CSSProperty = "font-style"
    static let fontVariant: CSSProperty = "font-variant"
    static let fontWeight: CSSProperty = "font-weight"
    static let hyphens: CSSProperty = "hyphens"
    static let letterSpacing: CSSProperty = "letter-spacing"
    static let lineHeight: CSSProperty = "line-height"
    static let tabSize: CSSProperty = "tab-size"
    static let textAlign: CSSProperty = "text-align"
    static let textDecoration: CSSProperty = "text-decoration"
    static let textDecorationColor: CSSProperty = "text-decoration-color"
    static let textDecorationLine: CSSProperty = "text-decoration-line"
    static let textDecorationStyle: CSSProperty = "text-decoration-style"
    static let textEmphasis: CSSProperty = "text-emphasis"
    static let textIndent: CSSProperty = "text-indent"
    static let textOverflow: CSSProperty = "text-overflow"
    static let textRendering: CSSProperty = "text-rendering"
    static let textShadow: CSSProperty = "text-shadow"
    static let textTransform: CSSProperty = "text-transform"
    static let unicodeBidi: CSSProperty = "unicode-bidi"
    static let verticalAlign: CSSProperty = "vertical-align"
    static let whiteSpace: CSSProperty = "white-space"
    static let wordBreak: CSSProperty = "word-break"
    static let wordSpacing: CSSProperty = "word-spacing"
    static let writingMode: CSSProperty = "writing-mode"
}

public extension Markup {
    func direction(_ value: CSSValue) -> some Markup {
        css(.direction, value)
    }

    func font(_ value: CSSValue) -> some Markup {
        css(.font, value)
    }

    func fontFamily(_ value: CSSValue) -> some Markup {
        css(.fontFamily, value)
    }

    func fontFeatureSettings(_ value: CSSValue) -> some Markup {
        css(.fontFeatureSettings, value)
    }

    func fontKerning(_ value: CSSValue) -> some Markup {
        css(.fontKerning, value)
    }

    func fontOpticalSizing(_ value: CSSValue) -> some Markup {
        css(.fontOpticalSizing, value)
    }

    func fontSize(_ value: CSSValue) -> some Markup {
        css(.fontSize, value)
    }

    func fontSizeAdjust(_ value: CSSValue) -> some Markup {
        css(.fontSizeAdjust, value)
    }

    func fontStretch(_ value: CSSValue) -> some Markup {
        css(.fontStretch, value)
    }

    func fontStyle(_ value: CSSValue) -> some Markup {
        css(.fontStyle, value)
    }

    func fontVariant(_ value: CSSValue) -> some Markup {
        css(.fontVariant, value)
    }

    func fontWeight(_ value: CSSValue) -> some Markup {
        css(.fontWeight, value)
    }

    func hyphens(_ value: CSSValue) -> some Markup {
        css(.hyphens, value)
    }

    func letterSpacing(_ value: CSSValue) -> some Markup {
        css(.letterSpacing, value)
    }

    func lineHeight(_ value: CSSValue) -> some Markup {
        css(.lineHeight, value)
    }

    func tabSize(_ value: CSSValue) -> some Markup {
        css(.tabSize, value)
    }

    func textAlign(_ value: CSSValue) -> some Markup {
        css(.textAlign, value)
    }

    func textDecoration(_ value: CSSValue) -> some Markup {
        css(.textDecoration, value)
    }

    func textDecorationColor(_ value: CSSValue) -> some Markup {
        css(.textDecorationColor, value)
    }

    func textDecorationLine(_ value: CSSValue) -> some Markup {
        css(.textDecorationLine, value)
    }

    func textDecorationStyle(_ value: CSSValue) -> some Markup {
        css(.textDecorationStyle, value)
    }

    func textEmphasis(_ value: CSSValue) -> some Markup {
        css(.textEmphasis, value)
    }

    func textIndent(_ value: CSSValue) -> some Markup {
        css(.textIndent, value)
    }

    func textOverflow(_ value: CSSValue) -> some Markup {
        css(.textOverflow, value)
    }

    func textRendering(_ value: CSSValue) -> some Markup {
        css(.textRendering, value)
    }

    func textShadow(_ value: CSSValue) -> some Markup {
        css(.textShadow, value)
    }

    func textTransform(_ value: CSSValue) -> some Markup {
        css(.textTransform, value)
    }

    func unicodeBidi(_ value: CSSValue) -> some Markup {
        css(.unicodeBidi, value)
    }

    func verticalAlign(_ value: CSSValue) -> some Markup {
        css(.verticalAlign, value)
    }

    func whiteSpace(_ value: CSSValue) -> some Markup {
        css(.whiteSpace, value)
    }

    func wordBreak(_ value: CSSValue) -> some Markup {
        css(.wordBreak, value)
    }

    func wordSpacing(_ value: CSSValue) -> some Markup {
        css(.wordSpacing, value)
    }

    func writingMode(_ value: CSSValue) -> some Markup {
        css(.writingMode, value)
    }

}

public extension VariantScope {
    func direction(_ value: CSSValue) {
        css(.direction, value)
    }

    func font(_ value: CSSValue) {
        css(.font, value)
    }

    func fontFamily(_ value: CSSValue) {
        css(.fontFamily, value)
    }

    func fontFeatureSettings(_ value: CSSValue) {
        css(.fontFeatureSettings, value)
    }

    func fontKerning(_ value: CSSValue) {
        css(.fontKerning, value)
    }

    func fontOpticalSizing(_ value: CSSValue) {
        css(.fontOpticalSizing, value)
    }

    func fontSize(_ value: CSSValue) {
        css(.fontSize, value)
    }

    func fontSizeAdjust(_ value: CSSValue) {
        css(.fontSizeAdjust, value)
    }

    func fontStretch(_ value: CSSValue) {
        css(.fontStretch, value)
    }

    func fontStyle(_ value: CSSValue) {
        css(.fontStyle, value)
    }

    func fontVariant(_ value: CSSValue) {
        css(.fontVariant, value)
    }

    func fontWeight(_ value: CSSValue) {
        css(.fontWeight, value)
    }

    func hyphens(_ value: CSSValue) {
        css(.hyphens, value)
    }

    func letterSpacing(_ value: CSSValue) {
        css(.letterSpacing, value)
    }

    func lineHeight(_ value: CSSValue) {
        css(.lineHeight, value)
    }

    func tabSize(_ value: CSSValue) {
        css(.tabSize, value)
    }

    func textAlign(_ value: CSSValue) {
        css(.textAlign, value)
    }

    func textDecoration(_ value: CSSValue) {
        css(.textDecoration, value)
    }

    func textDecorationColor(_ value: CSSValue) {
        css(.textDecorationColor, value)
    }

    func textDecorationLine(_ value: CSSValue) {
        css(.textDecorationLine, value)
    }

    func textDecorationStyle(_ value: CSSValue) {
        css(.textDecorationStyle, value)
    }

    func textEmphasis(_ value: CSSValue) {
        css(.textEmphasis, value)
    }

    func textIndent(_ value: CSSValue) {
        css(.textIndent, value)
    }

    func textOverflow(_ value: CSSValue) {
        css(.textOverflow, value)
    }

    func textRendering(_ value: CSSValue) {
        css(.textRendering, value)
    }

    func textShadow(_ value: CSSValue) {
        css(.textShadow, value)
    }

    func textTransform(_ value: CSSValue) {
        css(.textTransform, value)
    }

    func unicodeBidi(_ value: CSSValue) {
        css(.unicodeBidi, value)
    }

    func verticalAlign(_ value: CSSValue) {
        css(.verticalAlign, value)
    }

    func whiteSpace(_ value: CSSValue) {
        css(.whiteSpace, value)
    }

    func wordBreak(_ value: CSSValue) {
        css(.wordBreak, value)
    }

    func wordSpacing(_ value: CSSValue) {
        css(.wordSpacing, value)
    }

    func writingMode(_ value: CSSValue) {
        css(.writingMode, value)
    }

}
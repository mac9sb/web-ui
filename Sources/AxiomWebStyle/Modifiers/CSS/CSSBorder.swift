import Foundation
import AxiomWebUI

public extension CSSProperty {
    static let border: CSSProperty = "border"
    static let borderBlock: CSSProperty = "border-block"
    static let borderBlockColor: CSSProperty = "border-block-color"
    static let borderBlockStyle: CSSProperty = "border-block-style"
    static let borderBlockWidth: CSSProperty = "border-block-width"
    static let borderBottom: CSSProperty = "border-bottom"
    static let borderBottomColor: CSSProperty = "border-bottom-color"
    static let borderBottomLeftRadius: CSSProperty = "border-bottom-left-radius"
    static let borderBottomRightRadius: CSSProperty = "border-bottom-right-radius"
    static let borderBottomStyle: CSSProperty = "border-bottom-style"
    static let borderBottomWidth: CSSProperty = "border-bottom-width"
    static let borderCollapse: CSSProperty = "border-collapse"
    static let borderColor: CSSProperty = "border-color"
    static let borderImage: CSSProperty = "border-image"
    static let borderInline: CSSProperty = "border-inline"
    static let borderInlineColor: CSSProperty = "border-inline-color"
    static let borderInlineStyle: CSSProperty = "border-inline-style"
    static let borderInlineWidth: CSSProperty = "border-inline-width"
    static let borderLeft: CSSProperty = "border-left"
    static let borderLeftColor: CSSProperty = "border-left-color"
    static let borderLeftStyle: CSSProperty = "border-left-style"
    static let borderLeftWidth: CSSProperty = "border-left-width"
    static let borderRadius: CSSProperty = "border-radius"
    static let borderRight: CSSProperty = "border-right"
    static let borderRightColor: CSSProperty = "border-right-color"
    static let borderRightStyle: CSSProperty = "border-right-style"
    static let borderRightWidth: CSSProperty = "border-right-width"
    static let borderSpacing: CSSProperty = "border-spacing"
    static let borderStyle: CSSProperty = "border-style"
    static let borderTop: CSSProperty = "border-top"
    static let borderTopColor: CSSProperty = "border-top-color"
    static let borderTopLeftRadius: CSSProperty = "border-top-left-radius"
    static let borderTopRightRadius: CSSProperty = "border-top-right-radius"
    static let borderTopStyle: CSSProperty = "border-top-style"
    static let borderTopWidth: CSSProperty = "border-top-width"
    static let borderWidth: CSSProperty = "border-width"
    static let boxShadow: CSSProperty = "box-shadow"
    static let outline: CSSProperty = "outline"
    static let outlineColor: CSSProperty = "outline-color"
    static let outlineOffset: CSSProperty = "outline-offset"
    static let outlineStyle: CSSProperty = "outline-style"
    static let outlineWidth: CSSProperty = "outline-width"
}

public extension Markup {
    func border(_ value: CSSValue) -> some Markup {
        css(.border, value)
    }

    func borderBlock(_ value: CSSValue) -> some Markup {
        css(.borderBlock, value)
    }

    func borderBlockColor(_ value: CSSValue) -> some Markup {
        css(.borderBlockColor, value)
    }

    func borderBlockStyle(_ value: CSSValue) -> some Markup {
        css(.borderBlockStyle, value)
    }

    func borderBlockWidth(_ value: CSSValue) -> some Markup {
        css(.borderBlockWidth, value)
    }

    func borderBottom(_ value: CSSValue) -> some Markup {
        css(.borderBottom, value)
    }

    func borderBottomColor(_ value: CSSValue) -> some Markup {
        css(.borderBottomColor, value)
    }

    func borderBottomLeftRadius(_ value: CSSValue) -> some Markup {
        css(.borderBottomLeftRadius, value)
    }

    func borderBottomRightRadius(_ value: CSSValue) -> some Markup {
        css(.borderBottomRightRadius, value)
    }

    func borderBottomStyle(_ value: CSSValue) -> some Markup {
        css(.borderBottomStyle, value)
    }

    func borderBottomWidth(_ value: CSSValue) -> some Markup {
        css(.borderBottomWidth, value)
    }

    func borderCollapse(_ value: CSSValue) -> some Markup {
        css(.borderCollapse, value)
    }

    func borderColor(_ value: CSSValue) -> some Markup {
        css(.borderColor, value)
    }

    func borderImage(_ value: CSSValue) -> some Markup {
        css(.borderImage, value)
    }

    func borderInline(_ value: CSSValue) -> some Markup {
        css(.borderInline, value)
    }

    func borderInlineColor(_ value: CSSValue) -> some Markup {
        css(.borderInlineColor, value)
    }

    func borderInlineStyle(_ value: CSSValue) -> some Markup {
        css(.borderInlineStyle, value)
    }

    func borderInlineWidth(_ value: CSSValue) -> some Markup {
        css(.borderInlineWidth, value)
    }

    func borderLeft(_ value: CSSValue) -> some Markup {
        css(.borderLeft, value)
    }

    func borderLeftColor(_ value: CSSValue) -> some Markup {
        css(.borderLeftColor, value)
    }

    func borderLeftStyle(_ value: CSSValue) -> some Markup {
        css(.borderLeftStyle, value)
    }

    func borderLeftWidth(_ value: CSSValue) -> some Markup {
        css(.borderLeftWidth, value)
    }

    func borderRadius(_ value: CSSValue) -> some Markup {
        css(.borderRadius, value)
    }

    func borderRight(_ value: CSSValue) -> some Markup {
        css(.borderRight, value)
    }

    func borderRightColor(_ value: CSSValue) -> some Markup {
        css(.borderRightColor, value)
    }

    func borderRightStyle(_ value: CSSValue) -> some Markup {
        css(.borderRightStyle, value)
    }

    func borderRightWidth(_ value: CSSValue) -> some Markup {
        css(.borderRightWidth, value)
    }

    func borderSpacing(_ value: CSSValue) -> some Markup {
        css(.borderSpacing, value)
    }

    func borderStyle(_ value: CSSValue) -> some Markup {
        css(.borderStyle, value)
    }

    func borderTop(_ value: CSSValue) -> some Markup {
        css(.borderTop, value)
    }

    func borderTopColor(_ value: CSSValue) -> some Markup {
        css(.borderTopColor, value)
    }

    func borderTopLeftRadius(_ value: CSSValue) -> some Markup {
        css(.borderTopLeftRadius, value)
    }

    func borderTopRightRadius(_ value: CSSValue) -> some Markup {
        css(.borderTopRightRadius, value)
    }

    func borderTopStyle(_ value: CSSValue) -> some Markup {
        css(.borderTopStyle, value)
    }

    func borderTopWidth(_ value: CSSValue) -> some Markup {
        css(.borderTopWidth, value)
    }

    func borderWidth(_ value: CSSValue) -> some Markup {
        css(.borderWidth, value)
    }

    func boxShadow(_ value: CSSValue) -> some Markup {
        css(.boxShadow, value)
    }

    func outline(_ value: CSSValue) -> some Markup {
        css(.outline, value)
    }

    func outlineColor(_ value: CSSValue) -> some Markup {
        css(.outlineColor, value)
    }

    func outlineOffset(_ value: CSSValue) -> some Markup {
        css(.outlineOffset, value)
    }

    func outlineStyle(_ value: CSSValue) -> some Markup {
        css(.outlineStyle, value)
    }

    func outlineWidth(_ value: CSSValue) -> some Markup {
        css(.outlineWidth, value)
    }

}

public extension VariantScope {
    func border(_ value: CSSValue) {
        css(.border, value)
    }

    func borderBlock(_ value: CSSValue) {
        css(.borderBlock, value)
    }

    func borderBlockColor(_ value: CSSValue) {
        css(.borderBlockColor, value)
    }

    func borderBlockStyle(_ value: CSSValue) {
        css(.borderBlockStyle, value)
    }

    func borderBlockWidth(_ value: CSSValue) {
        css(.borderBlockWidth, value)
    }

    func borderBottom(_ value: CSSValue) {
        css(.borderBottom, value)
    }

    func borderBottomColor(_ value: CSSValue) {
        css(.borderBottomColor, value)
    }

    func borderBottomLeftRadius(_ value: CSSValue) {
        css(.borderBottomLeftRadius, value)
    }

    func borderBottomRightRadius(_ value: CSSValue) {
        css(.borderBottomRightRadius, value)
    }

    func borderBottomStyle(_ value: CSSValue) {
        css(.borderBottomStyle, value)
    }

    func borderBottomWidth(_ value: CSSValue) {
        css(.borderBottomWidth, value)
    }

    func borderCollapse(_ value: CSSValue) {
        css(.borderCollapse, value)
    }

    func borderColor(_ value: CSSValue) {
        css(.borderColor, value)
    }

    func borderImage(_ value: CSSValue) {
        css(.borderImage, value)
    }

    func borderInline(_ value: CSSValue) {
        css(.borderInline, value)
    }

    func borderInlineColor(_ value: CSSValue) {
        css(.borderInlineColor, value)
    }

    func borderInlineStyle(_ value: CSSValue) {
        css(.borderInlineStyle, value)
    }

    func borderInlineWidth(_ value: CSSValue) {
        css(.borderInlineWidth, value)
    }

    func borderLeft(_ value: CSSValue) {
        css(.borderLeft, value)
    }

    func borderLeftColor(_ value: CSSValue) {
        css(.borderLeftColor, value)
    }

    func borderLeftStyle(_ value: CSSValue) {
        css(.borderLeftStyle, value)
    }

    func borderLeftWidth(_ value: CSSValue) {
        css(.borderLeftWidth, value)
    }

    func borderRadius(_ value: CSSValue) {
        css(.borderRadius, value)
    }

    func borderRight(_ value: CSSValue) {
        css(.borderRight, value)
    }

    func borderRightColor(_ value: CSSValue) {
        css(.borderRightColor, value)
    }

    func borderRightStyle(_ value: CSSValue) {
        css(.borderRightStyle, value)
    }

    func borderRightWidth(_ value: CSSValue) {
        css(.borderRightWidth, value)
    }

    func borderSpacing(_ value: CSSValue) {
        css(.borderSpacing, value)
    }

    func borderStyle(_ value: CSSValue) {
        css(.borderStyle, value)
    }

    func borderTop(_ value: CSSValue) {
        css(.borderTop, value)
    }

    func borderTopColor(_ value: CSSValue) {
        css(.borderTopColor, value)
    }

    func borderTopLeftRadius(_ value: CSSValue) {
        css(.borderTopLeftRadius, value)
    }

    func borderTopRightRadius(_ value: CSSValue) {
        css(.borderTopRightRadius, value)
    }

    func borderTopStyle(_ value: CSSValue) {
        css(.borderTopStyle, value)
    }

    func borderTopWidth(_ value: CSSValue) {
        css(.borderTopWidth, value)
    }

    func borderWidth(_ value: CSSValue) {
        css(.borderWidth, value)
    }

    func boxShadow(_ value: CSSValue) {
        css(.boxShadow, value)
    }

    func outline(_ value: CSSValue) {
        css(.outline, value)
    }

    func outlineColor(_ value: CSSValue) {
        css(.outlineColor, value)
    }

    func outlineOffset(_ value: CSSValue) {
        css(.outlineOffset, value)
    }

    func outlineStyle(_ value: CSSValue) {
        css(.outlineStyle, value)
    }

    func outlineWidth(_ value: CSSValue) {
        css(.outlineWidth, value)
    }

}
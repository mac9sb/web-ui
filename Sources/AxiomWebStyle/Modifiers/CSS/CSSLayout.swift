import Foundation
import AxiomWebUI

public extension CSSProperty {
    static let aspectRatio: CSSProperty = "aspect-ratio"
    static let blockSize: CSSProperty = "block-size"
    static let bottom: CSSProperty = "bottom"
    static let boxSizing: CSSProperty = "box-sizing"
    static let clear: CSSProperty = "clear"
    static let container: CSSProperty = "container"
    static let containerName: CSSProperty = "container-name"
    static let containerType: CSSProperty = "container-type"
    static let display: CSSProperty = "display"
    static let float: CSSProperty = "float"
    static let height: CSSProperty = "height"
    static let inset: CSSProperty = "inset"
    static let insetBlock: CSSProperty = "inset-block"
    static let insetBlockEnd: CSSProperty = "inset-block-end"
    static let insetBlockStart: CSSProperty = "inset-block-start"
    static let insetInline: CSSProperty = "inset-inline"
    static let insetInlineEnd: CSSProperty = "inset-inline-end"
    static let insetInlineStart: CSSProperty = "inset-inline-start"
    static let isolation: CSSProperty = "isolation"
    static let left: CSSProperty = "left"
    static let margin: CSSProperty = "margin"
    static let marginBlock: CSSProperty = "margin-block"
    static let marginBlockEnd: CSSProperty = "margin-block-end"
    static let marginBlockStart: CSSProperty = "margin-block-start"
    static let marginBottom: CSSProperty = "margin-bottom"
    static let marginInline: CSSProperty = "margin-inline"
    static let marginInlineEnd: CSSProperty = "margin-inline-end"
    static let marginInlineStart: CSSProperty = "margin-inline-start"
    static let marginLeft: CSSProperty = "margin-left"
    static let marginRight: CSSProperty = "margin-right"
    static let marginTop: CSSProperty = "margin-top"
    static let maxHeight: CSSProperty = "max-height"
    static let maxInlineSize: CSSProperty = "max-inline-size"
    static let maxWidth: CSSProperty = "max-width"
    static let minHeight: CSSProperty = "min-height"
    static let minInlineSize: CSSProperty = "min-inline-size"
    static let minWidth: CSSProperty = "min-width"
    static let overflow: CSSProperty = "overflow"
    static let overflowAnchor: CSSProperty = "overflow-anchor"
    static let overflowBlock: CSSProperty = "overflow-block"
    static let overflowClipMargin: CSSProperty = "overflow-clip-margin"
    static let overflowInline: CSSProperty = "overflow-inline"
    static let overflowWrap: CSSProperty = "overflow-wrap"
    static let overflowX: CSSProperty = "overflow-x"
    static let overflowY: CSSProperty = "overflow-y"
    static let padding: CSSProperty = "padding"
    static let paddingBlock: CSSProperty = "padding-block"
    static let paddingBlockEnd: CSSProperty = "padding-block-end"
    static let paddingBlockStart: CSSProperty = "padding-block-start"
    static let paddingBottom: CSSProperty = "padding-bottom"
    static let paddingInline: CSSProperty = "padding-inline"
    static let paddingInlineEnd: CSSProperty = "padding-inline-end"
    static let paddingInlineStart: CSSProperty = "padding-inline-start"
    static let paddingLeft: CSSProperty = "padding-left"
    static let paddingRight: CSSProperty = "padding-right"
    static let paddingTop: CSSProperty = "padding-top"
    static let position: CSSProperty = "position"
    static let resize: CSSProperty = "resize"
    static let right: CSSProperty = "right"
    static let top: CSSProperty = "top"
    static let visibility: CSSProperty = "visibility"
    static let width: CSSProperty = "width"
    static let zIndex: CSSProperty = "z-index"
}

public extension Markup {
    func aspectRatio(_ value: CSSValue) -> some Markup {
        css(.aspectRatio, value)
    }

    func blockSize(_ value: CSSValue) -> some Markup {
        css(.blockSize, value)
    }

    func bottom(_ value: CSSValue) -> some Markup {
        css(.bottom, value)
    }

    func boxSizing(_ value: CSSValue) -> some Markup {
        css(.boxSizing, value)
    }

    func clear(_ value: CSSValue) -> some Markup {
        css(.clear, value)
    }

    func container(_ value: CSSValue) -> some Markup {
        css(.container, value)
    }

    func containerName(_ value: CSSValue) -> some Markup {
        css(.containerName, value)
    }

    func containerType(_ value: CSSValue) -> some Markup {
        css(.containerType, value)
    }

    func display(_ value: CSSValue) -> some Markup {
        css(.display, value)
    }

    func float(_ value: CSSValue) -> some Markup {
        css(.float, value)
    }

    func height(_ value: CSSValue) -> some Markup {
        css(.height, value)
    }

    func inset(_ value: CSSValue) -> some Markup {
        css(.inset, value)
    }

    func insetBlock(_ value: CSSValue) -> some Markup {
        css(.insetBlock, value)
    }

    func insetBlockEnd(_ value: CSSValue) -> some Markup {
        css(.insetBlockEnd, value)
    }

    func insetBlockStart(_ value: CSSValue) -> some Markup {
        css(.insetBlockStart, value)
    }

    func insetInline(_ value: CSSValue) -> some Markup {
        css(.insetInline, value)
    }

    func insetInlineEnd(_ value: CSSValue) -> some Markup {
        css(.insetInlineEnd, value)
    }

    func insetInlineStart(_ value: CSSValue) -> some Markup {
        css(.insetInlineStart, value)
    }

    func isolation(_ value: CSSValue) -> some Markup {
        css(.isolation, value)
    }

    func left(_ value: CSSValue) -> some Markup {
        css(.left, value)
    }

    func margin(_ value: CSSValue) -> some Markup {
        css(.margin, value)
    }

    func marginBlock(_ value: CSSValue) -> some Markup {
        css(.marginBlock, value)
    }

    func marginBlockEnd(_ value: CSSValue) -> some Markup {
        css(.marginBlockEnd, value)
    }

    func marginBlockStart(_ value: CSSValue) -> some Markup {
        css(.marginBlockStart, value)
    }

    func marginBottom(_ value: CSSValue) -> some Markup {
        css(.marginBottom, value)
    }

    func marginInline(_ value: CSSValue) -> some Markup {
        css(.marginInline, value)
    }

    func marginInlineEnd(_ value: CSSValue) -> some Markup {
        css(.marginInlineEnd, value)
    }

    func marginInlineStart(_ value: CSSValue) -> some Markup {
        css(.marginInlineStart, value)
    }

    func marginLeft(_ value: CSSValue) -> some Markup {
        css(.marginLeft, value)
    }

    func marginRight(_ value: CSSValue) -> some Markup {
        css(.marginRight, value)
    }

    func marginTop(_ value: CSSValue) -> some Markup {
        css(.marginTop, value)
    }

    func maxHeight(_ value: CSSValue) -> some Markup {
        css(.maxHeight, value)
    }

    func maxInlineSize(_ value: CSSValue) -> some Markup {
        css(.maxInlineSize, value)
    }

    func maxWidth(_ value: CSSValue) -> some Markup {
        css(.maxWidth, value)
    }

    func minHeight(_ value: CSSValue) -> some Markup {
        css(.minHeight, value)
    }

    func minInlineSize(_ value: CSSValue) -> some Markup {
        css(.minInlineSize, value)
    }

    func minWidth(_ value: CSSValue) -> some Markup {
        css(.minWidth, value)
    }

    func overflow(_ value: CSSValue) -> some Markup {
        css(.overflow, value)
    }

    func overflowAnchor(_ value: CSSValue) -> some Markup {
        css(.overflowAnchor, value)
    }

    func overflowBlock(_ value: CSSValue) -> some Markup {
        css(.overflowBlock, value)
    }

    func overflowClipMargin(_ value: CSSValue) -> some Markup {
        css(.overflowClipMargin, value)
    }

    func overflowInline(_ value: CSSValue) -> some Markup {
        css(.overflowInline, value)
    }

    func overflowWrap(_ value: CSSValue) -> some Markup {
        css(.overflowWrap, value)
    }

    func overflowX(_ value: CSSValue) -> some Markup {
        css(.overflowX, value)
    }

    func overflowY(_ value: CSSValue) -> some Markup {
        css(.overflowY, value)
    }

    func padding(_ value: CSSValue) -> some Markup {
        css(.padding, value)
    }

    func paddingBlock(_ value: CSSValue) -> some Markup {
        css(.paddingBlock, value)
    }

    func paddingBlockEnd(_ value: CSSValue) -> some Markup {
        css(.paddingBlockEnd, value)
    }

    func paddingBlockStart(_ value: CSSValue) -> some Markup {
        css(.paddingBlockStart, value)
    }

    func paddingBottom(_ value: CSSValue) -> some Markup {
        css(.paddingBottom, value)
    }

    func paddingInline(_ value: CSSValue) -> some Markup {
        css(.paddingInline, value)
    }

    func paddingInlineEnd(_ value: CSSValue) -> some Markup {
        css(.paddingInlineEnd, value)
    }

    func paddingInlineStart(_ value: CSSValue) -> some Markup {
        css(.paddingInlineStart, value)
    }

    func paddingLeft(_ value: CSSValue) -> some Markup {
        css(.paddingLeft, value)
    }

    func paddingRight(_ value: CSSValue) -> some Markup {
        css(.paddingRight, value)
    }

    func paddingTop(_ value: CSSValue) -> some Markup {
        css(.paddingTop, value)
    }

    func position(_ value: CSSValue) -> some Markup {
        css(.position, value)
    }

    func resize(_ value: CSSValue) -> some Markup {
        css(.resize, value)
    }

    func right(_ value: CSSValue) -> some Markup {
        css(.right, value)
    }

    func top(_ value: CSSValue) -> some Markup {
        css(.top, value)
    }

    func visibility(_ value: CSSValue) -> some Markup {
        css(.visibility, value)
    }

    func width(_ value: CSSValue) -> some Markup {
        css(.width, value)
    }

    func zIndex(_ value: CSSValue) -> some Markup {
        css(.zIndex, value)
    }

}

public extension VariantScope {
    func aspectRatio(_ value: CSSValue) {
        css(.aspectRatio, value)
    }

    func blockSize(_ value: CSSValue) {
        css(.blockSize, value)
    }

    func bottom(_ value: CSSValue) {
        css(.bottom, value)
    }

    func boxSizing(_ value: CSSValue) {
        css(.boxSizing, value)
    }

    func clear(_ value: CSSValue) {
        css(.clear, value)
    }

    func container(_ value: CSSValue) {
        css(.container, value)
    }

    func containerName(_ value: CSSValue) {
        css(.containerName, value)
    }

    func containerType(_ value: CSSValue) {
        css(.containerType, value)
    }

    func display(_ value: CSSValue) {
        css(.display, value)
    }

    func float(_ value: CSSValue) {
        css(.float, value)
    }

    func height(_ value: CSSValue) {
        css(.height, value)
    }

    func inset(_ value: CSSValue) {
        css(.inset, value)
    }

    func insetBlock(_ value: CSSValue) {
        css(.insetBlock, value)
    }

    func insetBlockEnd(_ value: CSSValue) {
        css(.insetBlockEnd, value)
    }

    func insetBlockStart(_ value: CSSValue) {
        css(.insetBlockStart, value)
    }

    func insetInline(_ value: CSSValue) {
        css(.insetInline, value)
    }

    func insetInlineEnd(_ value: CSSValue) {
        css(.insetInlineEnd, value)
    }

    func insetInlineStart(_ value: CSSValue) {
        css(.insetInlineStart, value)
    }

    func isolation(_ value: CSSValue) {
        css(.isolation, value)
    }

    func left(_ value: CSSValue) {
        css(.left, value)
    }

    func margin(_ value: CSSValue) {
        css(.margin, value)
    }

    func marginBlock(_ value: CSSValue) {
        css(.marginBlock, value)
    }

    func marginBlockEnd(_ value: CSSValue) {
        css(.marginBlockEnd, value)
    }

    func marginBlockStart(_ value: CSSValue) {
        css(.marginBlockStart, value)
    }

    func marginBottom(_ value: CSSValue) {
        css(.marginBottom, value)
    }

    func marginInline(_ value: CSSValue) {
        css(.marginInline, value)
    }

    func marginInlineEnd(_ value: CSSValue) {
        css(.marginInlineEnd, value)
    }

    func marginInlineStart(_ value: CSSValue) {
        css(.marginInlineStart, value)
    }

    func marginLeft(_ value: CSSValue) {
        css(.marginLeft, value)
    }

    func marginRight(_ value: CSSValue) {
        css(.marginRight, value)
    }

    func marginTop(_ value: CSSValue) {
        css(.marginTop, value)
    }

    func maxHeight(_ value: CSSValue) {
        css(.maxHeight, value)
    }

    func maxInlineSize(_ value: CSSValue) {
        css(.maxInlineSize, value)
    }

    func maxWidth(_ value: CSSValue) {
        css(.maxWidth, value)
    }

    func minHeight(_ value: CSSValue) {
        css(.minHeight, value)
    }

    func minInlineSize(_ value: CSSValue) {
        css(.minInlineSize, value)
    }

    func minWidth(_ value: CSSValue) {
        css(.minWidth, value)
    }

    func overflow(_ value: CSSValue) {
        css(.overflow, value)
    }

    func overflowAnchor(_ value: CSSValue) {
        css(.overflowAnchor, value)
    }

    func overflowBlock(_ value: CSSValue) {
        css(.overflowBlock, value)
    }

    func overflowClipMargin(_ value: CSSValue) {
        css(.overflowClipMargin, value)
    }

    func overflowInline(_ value: CSSValue) {
        css(.overflowInline, value)
    }

    func overflowWrap(_ value: CSSValue) {
        css(.overflowWrap, value)
    }

    func overflowX(_ value: CSSValue) {
        css(.overflowX, value)
    }

    func overflowY(_ value: CSSValue) {
        css(.overflowY, value)
    }

    func padding(_ value: CSSValue) {
        css(.padding, value)
    }

    func paddingBlock(_ value: CSSValue) {
        css(.paddingBlock, value)
    }

    func paddingBlockEnd(_ value: CSSValue) {
        css(.paddingBlockEnd, value)
    }

    func paddingBlockStart(_ value: CSSValue) {
        css(.paddingBlockStart, value)
    }

    func paddingBottom(_ value: CSSValue) {
        css(.paddingBottom, value)
    }

    func paddingInline(_ value: CSSValue) {
        css(.paddingInline, value)
    }

    func paddingInlineEnd(_ value: CSSValue) {
        css(.paddingInlineEnd, value)
    }

    func paddingInlineStart(_ value: CSSValue) {
        css(.paddingInlineStart, value)
    }

    func paddingLeft(_ value: CSSValue) {
        css(.paddingLeft, value)
    }

    func paddingRight(_ value: CSSValue) {
        css(.paddingRight, value)
    }

    func paddingTop(_ value: CSSValue) {
        css(.paddingTop, value)
    }

    func position(_ value: CSSValue) {
        css(.position, value)
    }

    func resize(_ value: CSSValue) {
        css(.resize, value)
    }

    func right(_ value: CSSValue) {
        css(.right, value)
    }

    func top(_ value: CSSValue) {
        css(.top, value)
    }

    func visibility(_ value: CSSValue) {
        css(.visibility, value)
    }

    func width(_ value: CSSValue) {
        css(.width, value)
    }

    func zIndex(_ value: CSSValue) {
        css(.zIndex, value)
    }

}
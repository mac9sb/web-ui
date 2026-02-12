import Foundation
import AxiomWebUI

public extension CSSProperty {
    static let alignContent: CSSProperty = "align-content"
    static let alignItems: CSSProperty = "align-items"
    static let alignSelf: CSSProperty = "align-self"
    static let columnCount: CSSProperty = "column-count"
    static let columnFill: CSSProperty = "column-fill"
    static let columnGap: CSSProperty = "column-gap"
    static let columnRule: CSSProperty = "column-rule"
    static let columnRuleColor: CSSProperty = "column-rule-color"
    static let columnRuleStyle: CSSProperty = "column-rule-style"
    static let columnRuleWidth: CSSProperty = "column-rule-width"
    static let columnSpan: CSSProperty = "column-span"
    static let columnWidth: CSSProperty = "column-width"
    static let columns: CSSProperty = "columns"
    static let flex: CSSProperty = "flex"
    static let flexBasis: CSSProperty = "flex-basis"
    static let flexDirection: CSSProperty = "flex-direction"
    static let flexFlow: CSSProperty = "flex-flow"
    static let flexGrow: CSSProperty = "flex-grow"
    static let flexShrink: CSSProperty = "flex-shrink"
    static let flexWrap: CSSProperty = "flex-wrap"
    static let gap: CSSProperty = "gap"
    static let grid: CSSProperty = "grid"
    static let gridAutoColumns: CSSProperty = "grid-auto-columns"
    static let gridAutoFlow: CSSProperty = "grid-auto-flow"
    static let gridAutoRows: CSSProperty = "grid-auto-rows"
    static let gridColumn: CSSProperty = "grid-column"
    static let gridColumnEnd: CSSProperty = "grid-column-end"
    static let gridColumnStart: CSSProperty = "grid-column-start"
    static let gridRow: CSSProperty = "grid-row"
    static let gridRowEnd: CSSProperty = "grid-row-end"
    static let gridRowStart: CSSProperty = "grid-row-start"
    static let gridTemplate: CSSProperty = "grid-template"
    static let gridTemplateAreas: CSSProperty = "grid-template-areas"
    static let gridTemplateColumns: CSSProperty = "grid-template-columns"
    static let gridTemplateRows: CSSProperty = "grid-template-rows"
    static let justifyContent: CSSProperty = "justify-content"
    static let justifyItems: CSSProperty = "justify-items"
    static let justifySelf: CSSProperty = "justify-self"
    static let order: CSSProperty = "order"
    static let placeContent: CSSProperty = "place-content"
    static let placeItems: CSSProperty = "place-items"
    static let placeSelf: CSSProperty = "place-self"
    static let rowGap: CSSProperty = "row-gap"
}

public extension Markup {
    func alignContent(_ value: CSSValue) -> some Markup {
        css(.alignContent, value)
    }

    func alignItems(_ value: CSSValue) -> some Markup {
        css(.alignItems, value)
    }

    func alignSelf(_ value: CSSValue) -> some Markup {
        css(.alignSelf, value)
    }

    func columnCount(_ value: CSSValue) -> some Markup {
        css(.columnCount, value)
    }

    func columnFill(_ value: CSSValue) -> some Markup {
        css(.columnFill, value)
    }

    func columnGap(_ value: CSSValue) -> some Markup {
        css(.columnGap, value)
    }

    func columnRule(_ value: CSSValue) -> some Markup {
        css(.columnRule, value)
    }

    func columnRuleColor(_ value: CSSValue) -> some Markup {
        css(.columnRuleColor, value)
    }

    func columnRuleStyle(_ value: CSSValue) -> some Markup {
        css(.columnRuleStyle, value)
    }

    func columnRuleWidth(_ value: CSSValue) -> some Markup {
        css(.columnRuleWidth, value)
    }

    func columnSpan(_ value: CSSValue) -> some Markup {
        css(.columnSpan, value)
    }

    func columnWidth(_ value: CSSValue) -> some Markup {
        css(.columnWidth, value)
    }

    func columns(_ value: CSSValue) -> some Markup {
        css(.columns, value)
    }

    func flex(_ value: CSSValue) -> some Markup {
        css(.flex, value)
    }

    func flexBasis(_ value: CSSValue) -> some Markup {
        css(.flexBasis, value)
    }

    func flexDirection(_ value: CSSValue) -> some Markup {
        css(.flexDirection, value)
    }

    func flexFlow(_ value: CSSValue) -> some Markup {
        css(.flexFlow, value)
    }

    func flexGrow(_ value: CSSValue) -> some Markup {
        css(.flexGrow, value)
    }

    func flexShrink(_ value: CSSValue) -> some Markup {
        css(.flexShrink, value)
    }

    func flexWrap(_ value: CSSValue) -> some Markup {
        css(.flexWrap, value)
    }

    func gap(_ value: CSSValue) -> some Markup {
        css(.gap, value)
    }

    func grid(_ value: CSSValue) -> some Markup {
        css(.grid, value)
    }

    func gridAutoColumns(_ value: CSSValue) -> some Markup {
        css(.gridAutoColumns, value)
    }

    func gridAutoFlow(_ value: CSSValue) -> some Markup {
        css(.gridAutoFlow, value)
    }

    func gridAutoRows(_ value: CSSValue) -> some Markup {
        css(.gridAutoRows, value)
    }

    func gridColumn(_ value: CSSValue) -> some Markup {
        css(.gridColumn, value)
    }

    func gridColumnEnd(_ value: CSSValue) -> some Markup {
        css(.gridColumnEnd, value)
    }

    func gridColumnStart(_ value: CSSValue) -> some Markup {
        css(.gridColumnStart, value)
    }

    func gridRow(_ value: CSSValue) -> some Markup {
        css(.gridRow, value)
    }

    func gridRowEnd(_ value: CSSValue) -> some Markup {
        css(.gridRowEnd, value)
    }

    func gridRowStart(_ value: CSSValue) -> some Markup {
        css(.gridRowStart, value)
    }

    func gridTemplate(_ value: CSSValue) -> some Markup {
        css(.gridTemplate, value)
    }

    func gridTemplateAreas(_ value: CSSValue) -> some Markup {
        css(.gridTemplateAreas, value)
    }

    func gridTemplateColumns(_ value: CSSValue) -> some Markup {
        css(.gridTemplateColumns, value)
    }

    func gridTemplateRows(_ value: CSSValue) -> some Markup {
        css(.gridTemplateRows, value)
    }

    func justifyContent(_ value: CSSValue) -> some Markup {
        css(.justifyContent, value)
    }

    func justifyItems(_ value: CSSValue) -> some Markup {
        css(.justifyItems, value)
    }

    func justifySelf(_ value: CSSValue) -> some Markup {
        css(.justifySelf, value)
    }

    func order(_ value: CSSValue) -> some Markup {
        css(.order, value)
    }

    func placeContent(_ value: CSSValue) -> some Markup {
        css(.placeContent, value)
    }

    func placeItems(_ value: CSSValue) -> some Markup {
        css(.placeItems, value)
    }

    func placeSelf(_ value: CSSValue) -> some Markup {
        css(.placeSelf, value)
    }

    func rowGap(_ value: CSSValue) -> some Markup {
        css(.rowGap, value)
    }

}

public extension VariantScope {
    func alignContent(_ value: CSSValue) {
        css(.alignContent, value)
    }

    func alignItems(_ value: CSSValue) {
        css(.alignItems, value)
    }

    func alignSelf(_ value: CSSValue) {
        css(.alignSelf, value)
    }

    func columnCount(_ value: CSSValue) {
        css(.columnCount, value)
    }

    func columnFill(_ value: CSSValue) {
        css(.columnFill, value)
    }

    func columnGap(_ value: CSSValue) {
        css(.columnGap, value)
    }

    func columnRule(_ value: CSSValue) {
        css(.columnRule, value)
    }

    func columnRuleColor(_ value: CSSValue) {
        css(.columnRuleColor, value)
    }

    func columnRuleStyle(_ value: CSSValue) {
        css(.columnRuleStyle, value)
    }

    func columnRuleWidth(_ value: CSSValue) {
        css(.columnRuleWidth, value)
    }

    func columnSpan(_ value: CSSValue) {
        css(.columnSpan, value)
    }

    func columnWidth(_ value: CSSValue) {
        css(.columnWidth, value)
    }

    func columns(_ value: CSSValue) {
        css(.columns, value)
    }

    func flex(_ value: CSSValue) {
        css(.flex, value)
    }

    func flexBasis(_ value: CSSValue) {
        css(.flexBasis, value)
    }

    func flexDirection(_ value: CSSValue) {
        css(.flexDirection, value)
    }

    func flexFlow(_ value: CSSValue) {
        css(.flexFlow, value)
    }

    func flexGrow(_ value: CSSValue) {
        css(.flexGrow, value)
    }

    func flexShrink(_ value: CSSValue) {
        css(.flexShrink, value)
    }

    func flexWrap(_ value: CSSValue) {
        css(.flexWrap, value)
    }

    func gap(_ value: CSSValue) {
        css(.gap, value)
    }

    func grid(_ value: CSSValue) {
        css(.grid, value)
    }

    func gridAutoColumns(_ value: CSSValue) {
        css(.gridAutoColumns, value)
    }

    func gridAutoFlow(_ value: CSSValue) {
        css(.gridAutoFlow, value)
    }

    func gridAutoRows(_ value: CSSValue) {
        css(.gridAutoRows, value)
    }

    func gridColumn(_ value: CSSValue) {
        css(.gridColumn, value)
    }

    func gridColumnEnd(_ value: CSSValue) {
        css(.gridColumnEnd, value)
    }

    func gridColumnStart(_ value: CSSValue) {
        css(.gridColumnStart, value)
    }

    func gridRow(_ value: CSSValue) {
        css(.gridRow, value)
    }

    func gridRowEnd(_ value: CSSValue) {
        css(.gridRowEnd, value)
    }

    func gridRowStart(_ value: CSSValue) {
        css(.gridRowStart, value)
    }

    func gridTemplate(_ value: CSSValue) {
        css(.gridTemplate, value)
    }

    func gridTemplateAreas(_ value: CSSValue) {
        css(.gridTemplateAreas, value)
    }

    func gridTemplateColumns(_ value: CSSValue) {
        css(.gridTemplateColumns, value)
    }

    func gridTemplateRows(_ value: CSSValue) {
        css(.gridTemplateRows, value)
    }

    func justifyContent(_ value: CSSValue) {
        css(.justifyContent, value)
    }

    func justifyItems(_ value: CSSValue) {
        css(.justifyItems, value)
    }

    func justifySelf(_ value: CSSValue) {
        css(.justifySelf, value)
    }

    func order(_ value: CSSValue) {
        css(.order, value)
    }

    func placeContent(_ value: CSSValue) {
        css(.placeContent, value)
    }

    func placeItems(_ value: CSSValue) {
        css(.placeItems, value)
    }

    func placeSelf(_ value: CSSValue) {
        css(.placeSelf, value)
    }

    func rowGap(_ value: CSSValue) {
        css(.rowGap, value)
    }

}
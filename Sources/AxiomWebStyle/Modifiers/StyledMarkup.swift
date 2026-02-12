import Foundation
import AxiomWebUI
import AxiomWebI18n

public struct StyledMarkup<Content: Markup>: Markup {
    let content: Content
    let classes: [String]
    let attributes: [HTMLAttribute]

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        content.makeNodes(locale: locale).map { node in
            var result = node
            for cssClass in classes {
                result = result.addingAttribute(HTMLAttribute("class", cssClass))
            }
            for attribute in attributes {
                result = result.addingAttribute(attribute)
            }
            return result
        }
    }
}

public extension Markup {
    func modifier(_ className: String) -> some Markup {
        StyledMarkup(content: self, classes: [className], attributes: [])
    }

    func modifiers(_ classNames: [String]) -> some Markup {
        StyledMarkup(content: self, classes: classNames, attributes: [])
    }
}

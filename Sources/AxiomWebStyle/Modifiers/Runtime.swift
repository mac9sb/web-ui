import Foundation
import AxiomWebUI

public extension Markup {
    func on(_ content: (VariantBuilder) -> Void) -> some Markup {
        let builder = VariantBuilder()
        content(builder)
        return StyledMarkup(content: self, classes: builder.classNames, attributes: builder.runtimeAttributes)
    }
}

import Foundation
import AxiomWebUI

public extension Markup {
    func shadow(_ name: String = "md") -> some Markup {
        modifier("shadow-\(name)")
    }
}

import Foundation
import AxiomWebI18n

public protocol Document {
    associatedtype Body: Markup

    var metadata: Metadata { get }
    var path: String { get }

    @MarkupBuilder
    var body: Body { get }
}

public extension Document {
    var path: String { "index" }
}

public protocol Website {
    var metadata: Metadata { get }
    var routes: [any Document] { get throws }
    var locales: [LocaleCode] { get }
    var defaultLocale: LocaleCode { get }
}

public extension Website {
    var locales: [LocaleCode] { [.en] }
    var defaultLocale: LocaleCode { .en }
}

public struct BuildOptions: Sendable {
    public enum StructuredDataValidationMode: Sendable {
        case strict
        case permissive
    }

    public var structuredDataValidationMode: StructuredDataValidationMode

    public init(structuredDataValidationMode: StructuredDataValidationMode = .strict) {
        self.structuredDataValidationMode = structuredDataValidationMode
    }
}

import AxiomWebI18n

public struct LocalizedText: Markup {
    public let key: LocalizedStringKey
    public let table: LocalizedStringTable
    public let fallback: LocaleCode

    public init(_ key: LocalizedStringKey, from table: LocalizedStringTable, fallback: LocaleCode = .en) {
        self.key = key
        self.table = table
        self.fallback = fallback
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.text(table.resolve(key, locale: locale, fallback: fallback))]
    }
}

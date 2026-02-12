public extension LocalizedString {
    init(_ value: String, locale: LocaleCode = .en) {
        self.init([locale: value])
    }
}

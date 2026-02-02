import Foundation

public enum DialogKind: Sendable {
    case alert
    case confirm
    case prompt
}

@MainActor
public final class Dialog {
    public let kind: DialogKind
    public let message: String
    public let defaultText: String?

    private let completion: Completion
    private var didComplete = false

    enum Completion {
        case alert(() -> Void)
        case confirm((Bool) -> Void)
        case prompt((String?) -> Void)
    }

    init(kind: DialogKind, message: String, defaultText: String?, completion: Completion) {
        self.kind = kind
        self.message = message
        self.defaultText = defaultText
        self.completion = completion
    }

    public var isHandled: Bool {
        didComplete
    }

    public func accept(_ text: String? = nil) {
        guard !didComplete else { return }
        didComplete = true
        switch completion {
        case .alert(let handler):
            handler()
        case .confirm(let handler):
            handler(true)
        case .prompt(let handler):
            handler(text ?? defaultText)
        }
    }

    public func dismiss() {
        guard !didComplete else { return }
        didComplete = true
        switch completion {
        case .alert(let handler):
            handler()
        case .confirm(let handler):
            handler(false)
        case .prompt(let handler):
            handler(nil)
        }
    }

    func performDefaultAction() {
        switch kind {
        case .alert:
            accept()
        case .confirm, .prompt:
            dismiss()
        }
    }
}

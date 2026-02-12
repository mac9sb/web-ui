import Foundation

public enum FormFieldType: Sendable, Equatable {
    case text
    case email
    case password
    case number
    case date
    case checkbox
    case custom(String)
}

public struct FormField: Sendable, Equatable {
    public let name: String
    public let type: FormFieldType
    public let required: Bool

    public init(name: String, type: FormFieldType, required: Bool = false) {
        self.name = name
        self.type = type
        self.required = required
    }
}

public enum FormValidationError: Error, Sendable, Equatable {
    case missingRequiredField(String)
    case invalidEmail(String)
    case invalidNumber(String)
    case custom(field: String, message: String)
}

public struct FormSchema: Sendable {
    public typealias CustomValidator = @Sendable (_ value: String) -> String?

    public struct Rule: Sendable {
        public let field: FormField
        public let customValidator: CustomValidator?

        public init(field: FormField, customValidator: CustomValidator? = nil) {
            self.field = field
            self.customValidator = customValidator
        }
    }

    private let rules: [Rule]

    public init(_ rules: [Rule]) {
        self.rules = rules
    }

    public func validate(_ values: [String: String]) -> [FormValidationError] {
        var errors: [FormValidationError] = []

        for rule in rules {
            let value = values[rule.field.name]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if rule.field.required, value.isEmpty {
                errors.append(.missingRequiredField(rule.field.name))
                continue
            }

            if value.isEmpty {
                continue
            }

            switch rule.field.type {
            case .email:
                if !value.contains("@") || !value.contains(".") {
                    errors.append(.invalidEmail(rule.field.name))
                }
            case .number:
                if Double(value) == nil {
                    errors.append(.invalidNumber(rule.field.name))
                }
            default:
                break
            }

            if let custom = rule.customValidator, let message = custom(value) {
                errors.append(.custom(field: rule.field.name, message: message))
            }
        }

        return errors
    }
}

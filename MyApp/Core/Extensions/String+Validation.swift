import Foundation

extension String {
    /// The string without leading and trailing whitespace and newlines.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Whether the trimmed string looks like a valid email address.
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    /// Whether the string looks like a phone number: an optional leading `+`, then 8–15 digits.
    /// Spaces, dashes, and parentheses are ignored (e.g. `"+855 12 345 678"`, `"012-345-678"`).
    var isValidPhoneNumber: Bool {
        let compact = trimmed.filter { !" -()".contains($0) }
        let pattern = #"^\+?[0-9]{8,15}$"#
        return compact.range(of: pattern, options: .regularExpression) != nil
    }
}

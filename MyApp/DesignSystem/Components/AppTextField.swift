import SwiftUI

/// Styled text input with an optional leading icon and secure-entry mode.
struct AppTextField: View {
    private let title: LocalizedStringKey
    @Binding private var text: String
    private let systemImage: String?
    private let isSecure: Bool
    private let keyboardType: UIKeyboardType
    private let textContentType: UITextContentType?
    private let accessibilityID: String

    /// Creates a text field.
    /// - Parameters:
    ///   - title: Placeholder text.
    ///   - text: Bound text value.
    ///   - systemImage: Optional SF Symbol shown before the field.
    ///   - isSecure: Hides input when `true` (passwords).
    ///   - keyboardType: Keyboard to present.
    ///   - textContentType: Autofill hint.
    ///   - accessibilityID: Identifier used by UI tests.
    init(
        _ title: LocalizedStringKey,
        text: Binding<String>,
        systemImage: String? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        accessibilityID: String = ""
    ) {
        self.title = title
        self._text = text
        self.systemImage = systemImage
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.accessibilityID = accessibilityID
    }

    private var disablesAutocorrection: Bool {
        isSecure || keyboardType == .emailAddress
    }

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(width: 20)
                    .accessibilityHidden(true)
            }

            Group {
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .textInputAutocapitalization(disablesAutocorrection ? .never : .sentences)
            .autocorrectionDisabled(disablesAutocorrection)
            .accessibilityIdentifier(accessibilityID)
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.medium))
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        AppTextField("Email", text: .constant(""), systemImage: "envelope", keyboardType: .emailAddress)
        AppTextField("Password", text: .constant("secret"), systemImage: "lock", isSecure: true)
    }
    .padding()
    .background(AppColor.background)
}

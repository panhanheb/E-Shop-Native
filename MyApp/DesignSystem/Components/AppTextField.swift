import SwiftUI

/// Styled text input with an optional label above, a leading icon, and secure entry
/// with a show/hide toggle.
struct AppTextField: View {
    private let title: LocalizedStringKey
    private let label: LocalizedStringKey?
    @Binding private var text: String
    private let systemImage: String?
    private let isSecure: Bool
    private let keyboardType: UIKeyboardType
    private let textContentType: UITextContentType?
    private let accessibilityID: String

    @State private var isRevealed = false

    /// Creates a text field.
    /// - Parameters:
    ///   - title: Placeholder text.
    ///   - label: Optional caption shown above the field.
    ///   - text: Bound text value.
    ///   - systemImage: Optional SF Symbol shown before the field.
    ///   - isSecure: Hides input when `true` (passwords) and adds a show/hide button.
    ///   - keyboardType: Keyboard to present.
    ///   - textContentType: Autofill hint.
    ///   - accessibilityID: Identifier used by UI tests.
    init(
        _ title: LocalizedStringKey,
        label: LocalizedStringKey? = nil,
        text: Binding<String>,
        systemImage: String? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        accessibilityID: String = ""
    ) {
        self.title = title
        self.label = label
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
        VStack(alignment: .leading, spacing: AppSpacing.xs + AppSpacing.xxs) {
            if let label {
                Text(label)
                    .font(AppFont.subheadline.weight(.medium))
                    .foregroundStyle(AppColors.textPrimary)
            }

            field
        }
    }

    private var field: some View {
        let shape = RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
        return HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: AppFontSize.iconSmall)
                    .accessibilityHidden(true)
            }

            Group {
                if isSecure && !isRevealed {
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

            if isSecure {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isRevealed ? Text("Hide Password") : Text("Show Password"))
            }
        }
        .font(AppFont.body)
        .padding(.horizontal, AppSpacing.md)
        .frame(minHeight: 52)
        .background(AppColors.surface, in: shape)
        .overlay(shape.strokeBorder(AppColors.border.opacity(0.7), lineWidth: 1))
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        AppTextField("you@example.com", label: "Email", text: .constant(""), systemImage: AppImages.email, keyboardType: .emailAddress)
        AppTextField("Password", label: "Password", text: .constant("secret"), systemImage: AppImages.password, isSecure: true)
    }
    .padding()
    .background(AppColors.background)
}

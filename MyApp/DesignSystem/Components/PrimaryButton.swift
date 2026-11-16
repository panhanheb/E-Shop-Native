import SwiftUI

/// Full-width call-to-action button with a built-in loading state.
struct PrimaryButton: View {
    private let title: LocalizedStringKey
    private let isLoading: Bool
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    /// Creates a primary button.
    /// - Parameters:
    ///   - title: Localized button title.
    ///   - isLoading: Shows a spinner and blocks taps while `true`.
    ///   - action: Called when the button is tapped.
    init(_ title: LocalizedStringKey, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView()
                        .tint(AppColors.onPrimary)
                }
            }
            .font(AppFont.headline)
            .foregroundStyle(AppColors.onPrimary)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(
                AppColors.primary.opacity(isEnabled ? 1 : 0.4),
                in: RoundedRectangle(cornerRadius: AppRadius.medium)
            )
            .contentShape(RoundedRectangle(cornerRadius: AppRadius.medium))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        PrimaryButton("Sign In") {}
        PrimaryButton("Sign In", isLoading: true) {}
        PrimaryButton("Sign In") {}
            .disabled(true)
    }
    .padding()
}

import SwiftUI

/// Full-width call-to-action button with a built-in loading state.
struct PrimaryButton: View {
    /// Visual weight of the button.
    enum Variant {
        /// Solid brand color: the main action on a screen.
        case filled
        /// Brand-colored outline: secondary actions.
        case outlined
        /// Red outline: destructive actions such as Sign Out.
        case destructive
    }

    private let title: LocalizedStringKey
    private let systemImage: String?
    private let variant: Variant
    private let isLoading: Bool
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    /// Creates a primary button.
    /// - Parameters:
    ///   - title: Localized button title.
    ///   - systemImage: Optional SF Symbol shown before the title.
    ///   - variant: Filled (default), outlined, or destructive.
    ///   - isLoading: Shows a spinner and blocks taps while `true`.
    ///   - action: Called when the button is tapped.
    init(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        variant: Variant = .filled,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.variant = variant
        self.isLoading = isLoading
        self.action = action
    }

    private var tint: Color {
        variant == .destructive ? AppColors.danger : AppColors.primary
    }

    private var foreground: Color {
        variant == .filled ? AppColors.onPrimary : tint
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
        Button(action: action) {
            ZStack {
                HStack(spacing: AppSpacing.sm) {
                    if let systemImage {
                        Image(systemName: systemImage)
                    }
                    Text(title)
                }
                .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(foreground)
                }
            }
            .font(AppFont.headline)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background {
                if variant == .filled {
                    shape.fill(tint)
                } else {
                    shape.fill(AppColors.surface)
                    shape.strokeBorder(tint.opacity(0.6), lineWidth: 1)
                }
            }
            .opacity(isEnabled ? 1 : 0.45)
            .contentShape(shape)
        }
        .buttonStyle(.pressable)
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        PrimaryButton("Sign In") {}
        PrimaryButton("Sign In", isLoading: true) {}
        PrimaryButton("Sign In") {}
            .disabled(true)
        PrimaryButton("Edit Profile", systemImage: "pencil", variant: .outlined) {}
        PrimaryButton("Sign Out", systemImage: AppImages.signOut, variant: .destructive) {}
    }
    .padding()
    .background(AppColors.background)
}

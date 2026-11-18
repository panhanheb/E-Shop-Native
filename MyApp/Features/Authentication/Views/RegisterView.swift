import SwiftUI

/// Account creation screen.
struct RegisterView: View {
    @State private var viewModel: RegisterViewModel
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name
        case email
        case password
        case confirmPassword
    }

    /// Creates the view with its view model.
    init(viewModel: RegisterViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                header
                form

                if let validationMessage = viewModel.validationMessage {
                    Label(validationMessage, systemImage: "info.circle")
                        .font(AppFont.footnote)
                        .foregroundStyle(AppColors.danger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                PrimaryButton("Create Account", isLoading: viewModel.isLoading) { submit() }
                    .disabled(!viewModel.canSubmit)
                    .accessibilityIdentifier("register.submit")

                Text("By creating an account, you agree to our Terms of Service and Privacy Policy.")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(AppSpacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Create Account")
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColors.textPrimary)
            Text("Create an account to shop and track your orders.")
                .font(AppFont.callout)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var form: some View {
        VStack(spacing: AppSpacing.md) {
            AppTextField(
                "Your full name",
                label: "Full Name",
                text: $viewModel.name,
                systemImage: AppImages.person,
                textContentType: .name
            )
            .focused($focusedField, equals: .name)
            .submitLabel(.next)
            .onSubmit { focusedField = .email }

            AppTextField(
                "you@example.com",
                label: "Email",
                text: $viewModel.email,
                systemImage: AppImages.email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            AppTextField(
                "At least \(RegisterRequest.minimumPasswordLength) characters",
                label: "Password",
                text: $viewModel.password,
                systemImage: AppImages.password,
                isSecure: true,
                textContentType: .newPassword
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.next)
            .onSubmit { focusedField = .confirmPassword }

            AppTextField(
                "Re-enter your password",
                label: "Confirm Password",
                text: $viewModel.confirmPassword,
                systemImage: AppImages.confirmPassword,
                isSecure: true,
                textContentType: .newPassword
            )
            .focused($focusedField, equals: .confirmPassword)
            .submitLabel(.go)
            .onSubmit { submit() }
        }
    }

    private func submit() {
        focusedField = nil
        Task { await viewModel.register() }
    }
}

#Preview {
    NavigationStack {
        RegisterView(
            viewModel: RegisterViewModel(
                authService: MockAuthService(database: MockUserDatabase(), latency: .zero),
                onAuthenticated: { _ in }
            )
        )
    }
}

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
            VStack(spacing: AppSpacing.lg) {
                header
                form

                if let validationMessage = viewModel.validationMessage {
                    Text(validationMessage)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.danger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                PrimaryButton("Create Account", isLoading: viewModel.isLoading, action: submit)
                    .disabled(!viewModel.canSubmit)
                    .accessibilityIdentifier("register.submit")
            }
            .padding(AppSpacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColor.background)
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Create Account")
                .font(AppFont.largeTitle)
            Text("Start organizing your work in minutes.")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    private var form: some View {
        VStack(spacing: AppSpacing.md) {
            AppTextField("Full Name", text: $viewModel.name, systemImage: "person", textContentType: .name)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit { focusedField = .email }

            AppTextField(
                "Email",
                text: $viewModel.email,
                systemImage: "envelope",
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            AppTextField(
                "Password",
                text: $viewModel.password,
                systemImage: "lock",
                isSecure: true,
                textContentType: .newPassword
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.next)
            .onSubmit { focusedField = .confirmPassword }

            AppTextField(
                "Confirm Password",
                text: $viewModel.confirmPassword,
                systemImage: "lock.rotation",
                isSecure: true,
                textContentType: .newPassword
            )
            .focused($focusedField, equals: .confirmPassword)
            .submitLabel(.go)
            .onSubmit(submit)
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

import SwiftUI

/// Sign-in screen with an email/password form and a link to registration.
struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @Environment(AppDependencies.self) private var dependencies
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case email
        case password
    }

    /// Creates the view with its view model.
    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    header
                    form

                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(message: errorMessage)
                    }

                    PrimaryButton("Sign In", isLoading: viewModel.isLoading, action: submit)
                        .disabled(!viewModel.canSubmit)
                        .accessibilityIdentifier("login.submit")

                    NavigationLink("Don't have an account? Create one") {
                        RegisterView(viewModel: dependencies.makeRegisterViewModel())
                    }
                    .font(AppFont.callout)

                    if dependencies.isUsingMockServices {
                        demoHint
                    }
                }
                .padding(AppSpacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppColors.background)
        }
    }

    private var header: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: AppImages.checkmarkCircleFilled)
                .font(AppFont.icon(AppFontSize.iconLarge))
                .foregroundStyle(AppColors.primary)
                .accessibilityHidden(true)
            Text("Welcome Back")
                .font(AppFont.largeTitle)
            Text("Sign in to manage your tasks.")
                .font(AppFont.callout)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.top, AppSpacing.xl)
    }

    private var form: some View {
        VStack(spacing: AppSpacing.md) {
            AppTextField(
                "Email",
                text: $viewModel.email,
                systemImage: AppImages.email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                accessibilityID: "login.email"
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            AppTextField(
                "Password",
                text: $viewModel.password,
                systemImage: AppImages.password,
                isSecure: true,
                textContentType: .password,
                accessibilityID: "login.password"
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit(submit)
        }
    }

    private var demoHint: some View {
        Text("Demo account: \(MockUserDatabase.demoEmail) / \(MockUserDatabase.demoPassword)")
            .font(AppFont.caption)
            .foregroundStyle(AppColors.textSecondary)
            .multilineTextAlignment(.center)
    }

    private func submit() {
        focusedField = nil
        Task { await viewModel.login() }
    }
}

#Preview("English") {
    let dependencies = AppDependencies.preview
    LoginView(viewModel: dependencies.makeLoginViewModel())
        .environment(dependencies)
}

#Preview("Khmer") {
    let dependencies = AppDependencies.preview
    LoginView(viewModel: dependencies.makeLoginViewModel())
        .environment(dependencies)
        .environment(\.locale, Locale(identifier: "km"))
}

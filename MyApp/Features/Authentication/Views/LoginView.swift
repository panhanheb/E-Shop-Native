import SwiftUI

/// Sign-in screen with an email/password form and a link to registration.
struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @Environment(DependencyContainer.self) private var dependencies
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
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    header
                    form

                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(message: errorMessage)
                    }

                    PrimaryButton("Sign In", isLoading: viewModel.isLoading) { submit() }
                        .disabled(!viewModel.canSubmit)
                        .accessibilityIdentifier("login.submit")

                    if dependencies.isUsingMockServices {
                        demoAccountCard
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppColors.background)
            .safeAreaInset(edge: .bottom) { registerLink }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Image(AppImages.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Welcome Back")
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Sign in to start shopping.")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.top, AppSpacing.xl)
    }

    private var form: some View {
        VStack(spacing: AppSpacing.md) {
            AppTextField(
                "you@example.com",
                label: "Email",
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
                "Enter your password",
                label: "Password",
                text: $viewModel.password,
                systemImage: AppImages.password,
                isSecure: true,
                textContentType: .password,
                accessibilityID: "login.password"
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit { submit() }
        }
    }

    /// Mock backend only: shows the demo credentials and fills them in on tap.
    private var demoAccountCard: some View {
        Button {
            viewModel.email = MockUserDatabase.demoEmail
            viewModel.password = MockUserDatabase.demoPassword
        } label: {
            HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
                IconTile(systemImage: "person.badge.key", tint: AppColors.info)
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Use Demo Account")
                        .font(AppFont.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(verbatim: "\(MockUserDatabase.demoEmail) · \(MockUserDatabase.demoPassword)")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Image(systemName: AppImages.chevronRight)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(AppSpacing.sm + AppSpacing.xs)
            .cardStyle(cornerRadius: AppRadius.medium, hasShadow: false)
        }
        .buttonStyle(.pressable)
        .accessibilityHint(Text("Fills in the demo email and password"))
    }

    private var registerLink: some View {
        HStack(spacing: AppSpacing.xs) {
            Text("Don't have an account?")
                .foregroundStyle(AppColors.textSecondary)
            NavigationLink {
                RegisterView(viewModel: dependencies.makeRegisterViewModel())
            } label: {
                Text("Create One")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.primary)
            }
        }
        .font(AppFont.callout)
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.background)
    }

    private func submit() {
        focusedField = nil
        Task { await viewModel.login() }
    }
}

#Preview("English") {
    let dependencies = DependencyContainer.preview
    LoginView(viewModel: dependencies.makeLoginViewModel())
        .environment(dependencies)
}

#Preview("Khmer") {
    let dependencies = DependencyContainer.preview
    LoginView(viewModel: dependencies.makeLoginViewModel())
        .environment(dependencies)
        .environment(\.locale, Locale(identifier: "km"))
}

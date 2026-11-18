import SwiftUI

/// Shows the signed-in user's profile with edit and sign-out actions.
struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var isConfirmingSignOut = false
    @State private var isShowingSettings = false
    @Environment(DependencyContainer.self) private var dependencies

    /// Creates the view with its view model.
    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingSettings = true
                        } label: {
                            Label("Settings", systemImage: AppImages.settings)
                        }
                        .accessibilityIdentifier("profile.settings")
                    }
                }
                .sheet(isPresented: $isShowingSettings) {
                    SettingsView(viewModel: dependencies.settingsViewModel)
                }
                .sheet(isPresented: $viewModel.isEditing) {
                    EditProfileView(viewModel: viewModel)
                }
                .confirmationDialog(
                    "Sign out of your account?",
                    isPresented: $isConfirmingSignOut,
                    titleVisibility: .visible
                ) {
                    Button("Sign Out", role: .destructive) {
                        Task { await viewModel.signOut() }
                    }
                }
                .task { await viewModel.loadProfile() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let user = viewModel.user {
            profileContent(for: user)
        } else if let errorMessage = viewModel.errorMessage {
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.loadProfile() }
            }
        } else if viewModel.hasLoaded {
            EmptyStateView(
                title: "No Profile",
                systemImage: AppImages.profileMissing,
                message: "Your profile could not be found."
            )
        } else {
            LoadingView(message: "Loading profile…")
        }
    }

    private func profileContent(for user: User) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                CardView {
                    VStack(spacing: AppSpacing.md) {
                        AvatarView(name: user.name, size: 88)
                        VStack(spacing: AppSpacing.xs) {
                            Text(user.name)
                                .font(AppFont.title)
                            Text(user.email)
                                .font(AppFont.callout)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                if let errorMessage = viewModel.errorMessage, !viewModel.isEditing {
                    ErrorBanner(message: errorMessage)
                }

                CardView {
                    VStack(spacing: AppSpacing.md) {
                        LabeledContent("Email", value: user.email)
                        Divider()
                        LabeledContent("Member Since") {
                            Text(user.joinedAt, format: .dateTime.month(.wide).year())
                        }
                    }
                }

                PrimaryButton("Edit Profile") {
                    viewModel.beginEditing()
                }

                Button(role: .destructive) {
                    isConfirmingSignOut = true
                } label: {
                    if viewModel.isSigningOut {
                        ProgressView()
                    } else {
                        Label("Sign Out", systemImage: AppImages.signOut)
                    }
                }
                .disabled(viewModel.isSigningOut)
                .accessibilityIdentifier("profile.signOut")
            }
            .padding(AppSpacing.md)
        }
        .refreshable { await viewModel.loadProfile() }
    }
}

#Preview {
    ProfileView(
        viewModel: ProfileViewModel(
            user: .mock,
            profileService: MockProfileService(database: MockUserDatabase(signedInUser: .mock), latency: .zero),
            onProfileUpdated: { _ in },
            onSignOut: {}
        )
    )
    .environment(DependencyContainer.preview)
}

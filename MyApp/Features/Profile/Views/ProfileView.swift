import SwiftUI

/// The signed-in user's profile: header with avatar, quick stats, an account menu, and sign out.
struct ProfileView: View {
    // swiftlint:disable:next force_unwrapping
    private static let privacyPolicyURL = URL(string: "https://example.com/privacy")!

    @State private var viewModel: ProfileViewModel
    @State private var isConfirmingSignOut = false
    @State private var isShowingSettings = false
    @State private var isShowingNotifications = false
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
                .sheet(isPresented: $isShowingNotifications) {
                    NotificationsView()
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
            VStack(spacing: AppSpacing.md) {
                header(for: user)

                if let errorMessage = viewModel.errorMessage, !viewModel.isEditing {
                    ErrorBanner(message: errorMessage)
                }

                stats(for: user)
                menu

                PrimaryButton("Sign Out", systemImage: AppImages.signOut, variant: .destructive, isLoading: viewModel.isSigningOut) {
                    isConfirmingSignOut = true
                }
                .disabled(viewModel.isSigningOut)
                .accessibilityIdentifier("profile.signOut")
                .padding(.top, AppSpacing.sm)

                Text("Version \(dependencies.settingsViewModel.appVersion)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(AppSpacing.md)
        }
        .refreshable { await viewModel.loadProfile() }
    }

    // MARK: Sections

    private func header(for user: User) -> some View {
        CardView {
            HStack(spacing: AppSpacing.md) {
                AvatarView(name: user.name, size: 64)
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(user.name)
                        .font(AppFont.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(user.email)
                        .font(AppFont.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Button {
                    viewModel.beginEditing()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 36, height: 36)
                        .background(AppColors.primarySoft, in: Circle())
                }
                .buttonStyle(.pressable)
                .accessibilityLabel(Text("Edit Profile"))
            }
        }
    }

    private func stats(for user: User) -> some View {
        HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
            stat(value: Text(dependencies.cartViewModel.itemCount, format: .number), title: "In Bag")
            stat(value: Text(dependencies.wishlistViewModel.count, format: .number), title: "Wishlist")
            stat(value: Text(user.joinedAt, format: .dateTime.year()), title: "Member Since")
        }
    }

    private func stat(value: Text, title: LocalizedStringKey) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            value
                .font(AppFont.title.monospacedDigit())
                .foregroundStyle(AppColors.textPrimary)
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm + AppSpacing.xs)
        .cardStyle(cornerRadius: AppRadius.medium)
        .accessibilityElement(children: .combine)
    }

    private var menu: some View {
        CardView(padding: 0) {
            VStack(spacing: 0) {
                menuRow("Edit Profile", systemImage: AppImages.person, tint: AppColors.primary) {
                    viewModel.beginEditing()
                }
                menuDivider
                menuRow("Notifications", systemImage: AppImages.notifications, tint: AppColors.accentAmber) {
                    isShowingNotifications = true
                }
                menuDivider
                menuRow("Settings", systemImage: AppImages.settings, tint: AppColors.accentBlue) {
                    isShowingSettings = true
                }
                menuDivider
                Link(destination: Self.privacyPolicyURL) {
                    menuRowLabel("Privacy Policy", systemImage: AppImages.privacy, tint: AppColors.accentTeal, trailingImage: "arrow.up.right")
                }
            }
        }
    }

    private var menuDivider: some View {
        Divider().padding(.leading, 60)
    }

    private func menuRow(
        _ title: LocalizedStringKey,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            menuRowLabel(title, systemImage: systemImage, tint: tint, trailingImage: AppImages.chevronRight)
        }
        .buttonStyle(.plain)
    }

    private func menuRowLabel(
        _ title: LocalizedStringKey,
        systemImage: String,
        tint: Color,
        trailingImage: String
    ) -> some View {
        HStack(spacing: AppSpacing.sm + AppSpacing.xs) {
            IconTile(systemImage: systemImage, tint: tint, size: 32)
            Text(title)
                .font(AppFont.body)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Image(systemName: trailingImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(minHeight: 52)
        .contentShape(Rectangle())
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

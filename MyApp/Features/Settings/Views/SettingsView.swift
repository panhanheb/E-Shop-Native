import SwiftUI

/// App preferences: appearance, notifications, haptics, and about info.
struct SettingsView: View {
    // swiftlint:disable:next force_unwrapping
    private static let privacyPolicyURL = URL(string: "https://example.com/privacy")!

    /// Shared app-wide so the root view can apply the appearance.
    @Bindable var viewModel: SettingsViewModel

    @Environment(\.openURL) private var openURL

    /// Name of the language the app is currently shown in, written in that language (e.g. "English", "ខ្មែរ").
    private var currentLanguageName: String {
        let code = Bundle.main.preferredLocalizations.first ?? "en"
        let locale = Locale(identifier: code)
        return locale.localizedString(forLanguageCode: code)?.capitalized(with: locale) ?? code
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && !viewModel.hasLoaded {
                    LoadingView(message: "Loading settings…")
                } else {
                    form
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var form: some View {
        Form {
            if let errorMessage = viewModel.errorMessage {
                Section {
                    ErrorBanner(message: errorMessage)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Appearance") {
                Picker("Theme", selection: $viewModel.appearance) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Toggle(isOn: $viewModel.notificationsEnabled) {
                    rowLabel("Notifications", systemImage: AppImages.notifications, tint: AppColors.accentAmber)
                }
                Toggle(isOn: $viewModel.hapticsEnabled) {
                    rowLabel("Haptic Feedback", systemImage: "iphone.radiowaves.left.and.right", tint: AppColors.accentViolet)
                }
            } header: {
                Text("Preferences")
            } footer: {
                Text("Notification delivery also requires permission in the iOS Settings app.")
            }

            Section {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                } label: {
                    LabeledContent {
                        HStack(spacing: AppSpacing.xs) {
                            Text(currentLanguageName)
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                    } label: {
                        rowLabel("Language", systemImage: AppImages.language, tint: AppColors.accentBlue)
                    }
                }
                .foregroundStyle(AppColors.textPrimary)
                .accessibilityIdentifier("settings.language")
            } footer: {
                Text("Opens iOS Settings, where you can choose English or Khmer for this app.")
            }

            Section("About") {
                LabeledContent {
                    Text(viewModel.appVersion)
                } label: {
                    rowLabel("Version", systemImage: "info.circle", tint: AppColors.textSecondary)
                }
                Link(destination: Self.privacyPolicyURL) {
                    LabeledContent {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.textTertiary)
                    } label: {
                        rowLabel("Privacy Policy", systemImage: AppImages.privacy, tint: AppColors.accentTeal)
                    }
                }
                .foregroundStyle(AppColors.textPrimary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
    }

    /// Settings-style row: tinted icon tile followed by the title.
    private func rowLabel(_ title: LocalizedStringKey, systemImage: String, tint: Color) -> some View {
        HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
            IconTile(systemImage: systemImage, tint: tint, size: 30)
            Text(title)
        }
    }
}

#Preview("English") {
    let viewModel = SettingsViewModel(settingsService: MockSettingsService(), appVersion: "1.0.0 (1)")
    SettingsView(viewModel: viewModel)
        .task { await viewModel.load() }
}

#Preview("Khmer") {
    let viewModel = SettingsViewModel(settingsService: MockSettingsService(), appVersion: "1.0.0 (1)")
    SettingsView(viewModel: viewModel)
        .task { await viewModel.load() }
        .environment(\.locale, Locale(identifier: "km"))
}

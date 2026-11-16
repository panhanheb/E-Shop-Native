import SwiftUI

/// Switches between launch, authentication, and main content based on the session.
struct RootView: View {
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        Group {
            switch dependencies.sessionStore.state {
            case .restoring:
                LoadingView()
            case .signedOut:
                LoginView(viewModel: dependencies.makeLoginViewModel())
            case .signedIn:
                MainTabView()
            }
        }
        .animation(.default, value: dependencies.sessionStore.state)
        .preferredColorScheme(dependencies.settingsViewModel.appearance.colorScheme)
        .task {
            await dependencies.settingsViewModel.load()
            await dependencies.sessionStore.restore()
        }
    }
}

#Preview("Signed In") {
    RootView()
        .environment(AppDependencies.preview)
}

#Preview("Signed Out") {
    RootView()
        .environment(AppDependencies.mock(latency: .zero, settingsService: MockSettingsService()))
}

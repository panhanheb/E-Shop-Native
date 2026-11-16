import SwiftUI

/// Tab bar shown once the user is signed in.
struct MainTabView: View {
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        TabView {
            HomeView(viewModel: dependencies.makeTaskListViewModel())
                .tabItem { Label("Tasks", systemImage: "checklist") }

            ProfileView(viewModel: dependencies.makeProfileViewModel())
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }

            SettingsView(viewModel: dependencies.settingsViewModel)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppDependencies.preview)
}

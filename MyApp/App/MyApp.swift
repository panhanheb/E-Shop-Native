import SwiftUI

/// Application entry point.
@main
struct MyApp: App {
    @State private var dependencies = DependencyContainer.make(for: .current)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
        }
    }
}

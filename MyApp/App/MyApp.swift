import SwiftUI

/// Application entry point.
@main
struct MyApp: App {
    @State private var dependencies = AppDependencies.make(for: .current)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
        }
    }
}

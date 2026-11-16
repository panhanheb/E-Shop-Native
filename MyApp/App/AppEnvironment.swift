import Foundation

/// Build/runtime configuration: which backend to use and how it behaves.
struct AppEnvironment: Sendable {
    /// Launch argument passed by UI tests to get a fast, deterministic mock backend.
    static let uiTestingArgument = "-ui-testing"

    /// Root URL of the REST API.
    let baseURL: URL
    /// Use in-memory mock services instead of the REST API.
    let useMockServices: Bool
    /// Simulated latency for mock services.
    let mockLatency: Duration

    /// The configuration for the current process.
    static var current: AppEnvironment {
        let isUITesting = ProcessInfo.processInfo.arguments.contains(uiTestingArgument)
        return AppEnvironment(
            // swiftlint:disable:next force_unwrapping
            baseURL: URL(string: "https://api.example.com/v1")!,
            // Flip to `false` once the backend is live.
            useMockServices: true,
            mockLatency: isUITesting ? .zero : .milliseconds(600)
        )
    }
}

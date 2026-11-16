import Foundation

/// Loads and saves `AppSettings`.
protocol SettingsServiceProtocol: Sendable {
    /// Returns stored settings, or `AppSettings.default` if none were saved.
    func loadSettings() async throws -> AppSettings

    /// Persists `settings`.
    func saveSettings(_ settings: AppSettings) async throws
}

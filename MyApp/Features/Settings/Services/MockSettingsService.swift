import Foundation

/// In-memory `SettingsServiceProtocol` for previews.
actor MockSettingsService: SettingsServiceProtocol {
    private var settings: AppSettings

    /// Creates the mock with initial `settings`.
    init(settings: AppSettings = .default) {
        self.settings = settings
    }

    func loadSettings() -> AppSettings {
        settings
    }

    func saveSettings(_ settings: AppSettings) {
        self.settings = settings
    }
}

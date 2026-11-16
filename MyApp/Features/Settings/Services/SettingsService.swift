import Foundation

/// `UserDefaults`-backed implementation of `SettingsServiceProtocol`.
///
/// `UserDefaults` is documented as thread-safe, so sharing it across isolation domains is safe.
final class SettingsService: SettingsServiceProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let key: String

    /// Creates the service.
    /// - Parameters:
    ///   - defaults: Store to read and write.
    ///   - key: Key the encoded settings are saved under.
    init(defaults: UserDefaults = .standard, key: String = "app.settings") {
        self.defaults = defaults
        self.key = key
    }

    func loadSettings() async throws -> AppSettings {
        guard let data = defaults.data(forKey: key) else {
            return .default
        }
        return try JSONDecoder().decode(AppSettings.self, from: data)
    }

    func saveSettings(_ settings: AppSettings) async throws {
        let data = try JSONEncoder().encode(settings)
        defaults.set(data, forKey: key)
    }
}

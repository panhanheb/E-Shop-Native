import Foundation
@testable import MyApp

/// Configurable `SettingsServiceProtocol` that records calls.
@MainActor
final class StubSettingsService: SettingsServiceProtocol {
    var storedSettings: AppSettings = .default
    var loadError: (any Error)?
    var saveError: (any Error)?

    private(set) var saveCallCount = 0

    func loadSettings() async throws -> AppSettings {
        if let loadError { throw loadError }
        return storedSettings
    }

    func saveSettings(_ settings: AppSettings) async throws {
        saveCallCount += 1
        if let saveError { throw saveError }
        storedSettings = settings
    }
}

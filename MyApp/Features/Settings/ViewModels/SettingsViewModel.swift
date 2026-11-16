import Foundation
import Observation

/// State and actions for the settings screen. Changes are applied immediately and saved in the background.
@Observable
@MainActor
final class SettingsViewModel {
    private(set) var settings: AppSettings = .default
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    var errorMessage: String?

    /// Version string shown in the About section.
    let appVersion: String

    private let settingsService: any SettingsServiceProtocol
    @ObservationIgnored private var saveTask: Task<Void, Never>?

    /// Creates the view model.
    init(settingsService: any SettingsServiceProtocol, appVersion: String) {
        self.settingsService = settingsService
        self.appVersion = appVersion
    }

    /// Preferred color scheme. Setting it saves immediately.
    var appearance: AppearanceMode {
        get { settings.appearance }
        set { apply { $0.appearance = newValue } }
    }

    /// Whether notifications are enabled. Setting it saves immediately.
    var notificationsEnabled: Bool {
        get { settings.notificationsEnabled }
        set { apply { $0.notificationsEnabled = newValue } }
    }

    /// Whether haptic feedback is enabled. Setting it saves immediately.
    var hapticsEnabled: Bool {
        get { settings.hapticsEnabled }
        set { apply { $0.hapticsEnabled = newValue } }
    }

    /// Loads stored settings, falling back to defaults on failure.
    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            settings = try await settingsService.loadSettings()
        } catch {
            settings = .default
            errorMessage = error.localizedDescription
        }
    }

    /// Waits for any in-flight save to finish.
    func waitForPendingSave() async {
        await saveTask?.value
    }

    private func apply(_ change: (inout AppSettings) -> Void) {
        let previous = settings
        var updated = settings
        change(&updated)
        guard updated != previous else { return }

        settings = updated
        errorMessage = nil
        saveTask = Task { await persist(updated, revertingTo: previous) }
    }

    private func persist(_ updated: AppSettings, revertingTo previous: AppSettings) async {
        do {
            try await settingsService.saveSettings(updated)
        } catch {
            if settings == updated {
                settings = previous
            }
            errorMessage = error.localizedDescription
        }
    }
}

import Foundation

/// User-configurable app preferences persisted on device.
struct AppSettings: Codable, Equatable, Sendable {
    var appearance: AppearanceMode
    var notificationsEnabled: Bool
    var hapticsEnabled: Bool

    /// Settings used before the user changes anything.
    static let `default` = AppSettings(appearance: .system, notificationsEnabled: true, hapticsEnabled: true)
}

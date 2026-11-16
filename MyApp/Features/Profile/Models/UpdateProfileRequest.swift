import Foundation

/// Editable profile fields sent to the server.
struct UpdateProfileRequest: Codable, Equatable, Sendable {
    let name: String
}

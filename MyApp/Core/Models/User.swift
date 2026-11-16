import Foundation

/// An authenticated user of the app.
struct User: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    var name: String
    var email: String
    var avatarURL: URL?
    let joinedAt: Date
}

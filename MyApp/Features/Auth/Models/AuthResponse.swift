import Foundation

/// Successful authentication result: a bearer token and the signed-in user.
struct AuthResponse: Codable, Equatable, Sendable {
    let token: String
    let user: User
}

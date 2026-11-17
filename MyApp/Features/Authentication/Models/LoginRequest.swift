import Foundation

/// Credentials submitted to sign in.
struct LoginRequest: Codable, Equatable, Sendable {
    let email: String
    let password: String
}

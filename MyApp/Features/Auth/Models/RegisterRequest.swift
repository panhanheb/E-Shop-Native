import Foundation

/// Details submitted to create a new account.
struct RegisterRequest: Codable, Equatable, Sendable {
    /// Minimum number of characters required for a new password.
    static let minimumPasswordLength = 8

    let name: String
    let email: String
    let password: String
}

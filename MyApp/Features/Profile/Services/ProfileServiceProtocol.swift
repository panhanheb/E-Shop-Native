import Foundation

/// Reads and updates the signed-in user's profile.
protocol ProfileServiceProtocol: Sendable {
    /// Returns the signed-in user.
    /// - Throws: `NetworkError.unauthorized` when the session is invalid.
    func fetchProfile() async throws -> User

    /// Applies `request` and returns the updated user.
    func updateProfile(_ request: UpdateProfileRequest) async throws -> User
}

import Foundation

/// Stores the authentication token for the current session.
protocol TokenStoreProtocol: Sendable {
    /// Returns the stored token, or `nil` when signed out.
    func token() async -> String?

    /// Persists `token`, replacing any existing value.
    func save(_ token: String) async throws

    /// Removes the stored token.
    func clear() async throws
}

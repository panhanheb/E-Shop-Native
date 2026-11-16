import Foundation

/// Authenticates users against the backend.
protocol AuthServiceProtocol: Sendable {
    /// Signs in with email and password.
    /// - Throws: `AuthError.invalidCredentials` or a `NetworkError`.
    func login(_ request: LoginRequest) async throws -> AuthResponse

    /// Creates an account and signs in.
    /// - Throws: `AuthError.emailAlreadyInUse` or a `NetworkError`.
    func register(_ request: RegisterRequest) async throws -> AuthResponse

    /// Invalidates the current session on the server.
    func logout() async throws
}

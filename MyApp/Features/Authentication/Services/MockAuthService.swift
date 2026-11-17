import Foundation

/// In-memory `AuthServiceProtocol` used until the backend is available, and in previews.
final class MockAuthService: AuthServiceProtocol {
    private let database: MockUserDatabase
    private let latency: Duration

    /// Creates the mock.
    /// - Parameters:
    ///   - database: Shared mock user store.
    ///   - latency: Simulated network delay.
    init(database: MockUserDatabase, latency: Duration = .milliseconds(600)) {
        self.database = database
        self.latency = latency
    }

    func login(_ request: LoginRequest) async throws -> AuthResponse {
        try await Task.sleep(for: latency)
        guard let user = await database.authenticate(email: request.email, password: request.password) else {
            throw AuthError.invalidCredentials
        }
        return AuthResponse(token: Self.makeToken(), user: user)
    }

    func register(_ request: RegisterRequest) async throws -> AuthResponse {
        try await Task.sleep(for: latency)
        guard let user = await database.createAccount(
            name: request.name,
            email: request.email,
            password: request.password
        ) else {
            throw AuthError.emailAlreadyInUse
        }
        return AuthResponse(token: Self.makeToken(), user: user)
    }

    func logout() async throws {
        try await Task.sleep(for: latency)
        await database.signOut()
    }

    private static func makeToken() -> String {
        "mock-token-\(UUID().uuidString)"
    }
}

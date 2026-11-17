import Foundation

/// REST implementation of `AuthServiceProtocol`.
final class AuthService: AuthServiceProtocol {
    private let apiClient: any APIClientProtocol

    /// Creates the service backed by `apiClient`.
    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func login(_ request: LoginRequest) async throws -> AuthResponse {
        do {
            return try await apiClient.send(Endpoint.login(request), as: AuthResponse.self)
        } catch NetworkError.unauthorized {
            throw AuthError.invalidCredentials
        }
    }

    func register(_ request: RegisterRequest) async throws -> AuthResponse {
        do {
            return try await apiClient.send(Endpoint.register(request), as: AuthResponse.self)
        } catch NetworkError.server(statusCode: 409) {
            throw AuthError.emailAlreadyInUse
        }
    }

    func logout() async throws {
        try await apiClient.send(.logout)
    }
}

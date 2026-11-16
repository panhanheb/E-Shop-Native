import Foundation
@testable import MyApp

/// Configurable `AuthServiceProtocol` that records calls.
@MainActor
final class StubAuthService: AuthServiceProtocol {
    var loginResult: Result<AuthResponse, any Error> = .success(AuthResponse(token: "token", user: .mock))
    var registerResult: Result<AuthResponse, any Error> = .success(AuthResponse(token: "token", user: .mock))
    var logoutError: (any Error)?

    private(set) var loginRequests: [LoginRequest] = []
    private(set) var registerRequests: [RegisterRequest] = []
    private(set) var logoutCallCount = 0

    func login(_ request: LoginRequest) async throws -> AuthResponse {
        loginRequests.append(request)
        return try loginResult.get()
    }

    func register(_ request: RegisterRequest) async throws -> AuthResponse {
        registerRequests.append(request)
        return try registerResult.get()
    }

    func logout() async throws {
        logoutCallCount += 1
        if let logoutError { throw logoutError }
    }
}

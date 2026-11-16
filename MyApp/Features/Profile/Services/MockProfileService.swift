import Foundation

/// In-memory `ProfileServiceProtocol` used until the backend is available, and in previews.
final class MockProfileService: ProfileServiceProtocol {
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

    func fetchProfile() async throws -> User {
        try await Task.sleep(for: latency)
        guard let user = await database.currentUser() else {
            throw NetworkError.unauthorized
        }
        return user
    }

    func updateProfile(_ request: UpdateProfileRequest) async throws -> User {
        try await Task.sleep(for: latency)
        guard let user = await database.updateCurrentUser(name: request.name) else {
            throw NetworkError.unauthorized
        }
        return user
    }
}

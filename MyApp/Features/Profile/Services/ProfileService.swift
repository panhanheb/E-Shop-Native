import Foundation

/// REST implementation of `ProfileServiceProtocol`.
final class ProfileService: ProfileServiceProtocol {
    private let apiClient: any APIClientProtocol

    /// Creates the service backed by `apiClient`.
    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchProfile() async throws -> User {
        try await apiClient.send(.profile, as: User.self)
    }

    func updateProfile(_ request: UpdateProfileRequest) async throws -> User {
        try await apiClient.send(Endpoint.updateProfile(request), as: User.self)
    }
}

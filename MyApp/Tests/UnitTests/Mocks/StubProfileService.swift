import Foundation
@testable import MyApp

/// Configurable `ProfileServiceProtocol` that records calls.
@MainActor
final class StubProfileService: ProfileServiceProtocol {
    var user: User = .mock
    var fetchError: (any Error)?
    var updateError: (any Error)?

    private(set) var fetchCallCount = 0
    private(set) var updateRequests: [UpdateProfileRequest] = []

    func fetchProfile() async throws -> User {
        fetchCallCount += 1
        if let fetchError { throw fetchError }
        return user
    }

    func updateProfile(_ request: UpdateProfileRequest) async throws -> User {
        updateRequests.append(request)
        if let updateError { throw updateError }
        user.name = request.name
        return user
    }
}

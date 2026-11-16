import Foundation
import Observation

/// Owns the app's authentication state and token lifecycle.
@Observable
@MainActor
final class SessionStore {
    private(set) var state: SessionState = .restoring

    private let tokenStore: any TokenStoreProtocol
    private let authService: any AuthServiceProtocol
    private let profileService: any ProfileServiceProtocol

    /// Creates the store.
    init(
        tokenStore: any TokenStoreProtocol,
        authService: any AuthServiceProtocol,
        profileService: any ProfileServiceProtocol
    ) {
        self.tokenStore = tokenStore
        self.authService = authService
        self.profileService = profileService
    }

    /// The signed-in user, if any.
    var currentUser: User? {
        if case .signedIn(let user) = state {
            return user
        }
        return nil
    }

    /// Restores a previous session from the stored token at launch.
    func restore() async {
        guard state == .restoring else { return }

        guard await tokenStore.token() != nil else {
            state = .signedOut
            return
        }

        do {
            state = .signedIn(try await profileService.fetchProfile())
        } catch NetworkError.unauthorized {
            try? await tokenStore.clear()
            state = .signedOut
        } catch {
            // Keep the token so the next launch can retry (e.g. when offline).
            state = .signedOut
        }
    }

    /// Stores the token and marks the user as signed in.
    func signIn(with response: AuthResponse) async throws {
        try await tokenStore.save(response.token)
        state = .signedIn(response.user)
    }

    /// Replaces the cached user after a profile change.
    func updateUser(_ user: User) {
        guard case .signedIn = state else { return }
        state = .signedIn(user)
    }

    /// Ends the session locally and on the server (best effort).
    func signOut() async {
        try? await authService.logout()
        try? await tokenStore.clear()
        state = .signedOut
    }
}

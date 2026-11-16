import Foundation
import Observation

/// State and actions for the profile screen: loading, editing, and signing out.
@Observable
@MainActor
final class ProfileViewModel {
    private(set) var user: User?
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var isSaving = false
    private(set) var isSigningOut = false
    var errorMessage: String?
    var draftName = ""
    var isEditing = false

    private let profileService: any ProfileServiceProtocol
    private let onProfileUpdated: @MainActor (User) -> Void
    private let onSignOut: @MainActor () async -> Void

    /// Creates the view model.
    /// - Parameters:
    ///   - user: Cached user shown before the first fetch completes.
    ///   - profileService: Service used to fetch and update the profile.
    ///   - onProfileUpdated: Called whenever a newer user value is received.
    ///   - onSignOut: Performs the sign-out.
    init(
        user: User?,
        profileService: any ProfileServiceProtocol,
        onProfileUpdated: @escaping @MainActor (User) -> Void,
        onSignOut: @escaping @MainActor () async -> Void
    ) {
        self.user = user
        self.profileService = profileService
        self.onProfileUpdated = onProfileUpdated
        self.onSignOut = onSignOut
    }

    /// Whether the edited name is valid and different from the current one.
    var canSaveProfile: Bool {
        let name = draftName.trimmed
        return !name.isEmpty && name != user?.name && !isSaving
    }

    /// Fetches the latest profile.
    func loadProfile() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            let fetched = try await profileService.fetchProfile()
            user = fetched
            onProfileUpdated(fetched)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Opens the editor seeded with the current values.
    func beginEditing() {
        draftName = user?.name ?? ""
        errorMessage = nil
        isEditing = true
    }

    /// Closes the editor without saving.
    func cancelEditing() {
        isEditing = false
    }

    /// Saves the edited profile and closes the editor on success.
    func saveProfile() async {
        guard canSaveProfile else { return }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let updated = try await profileService.updateProfile(UpdateProfileRequest(name: draftName.trimmed))
            user = updated
            onProfileUpdated(updated)
            isEditing = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Signs the user out.
    func signOut() async {
        guard !isSigningOut else { return }
        isSigningOut = true
        defer { isSigningOut = false }
        await onSignOut()
    }
}

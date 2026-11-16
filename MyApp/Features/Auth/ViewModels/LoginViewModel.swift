import Foundation
import Observation

/// Drives the login screen: form input, validation, and submission.
@Observable
@MainActor
final class LoginViewModel {
    var email = ""
    var password = ""
    private(set) var isLoading = false
    var errorMessage: String?

    private let authService: any AuthServiceProtocol
    private let onAuthenticated: @MainActor (AuthResponse) async throws -> Void

    /// Creates the view model.
    /// - Parameters:
    ///   - authService: Service used to sign in.
    ///   - onAuthenticated: Called with the response after a successful sign-in.
    init(
        authService: any AuthServiceProtocol,
        onAuthenticated: @escaping @MainActor (AuthResponse) async throws -> Void
    ) {
        self.authService = authService
        self.onAuthenticated = onAuthenticated
    }

    /// Whether the form contains valid input and can be submitted.
    var canSubmit: Bool {
        email.isValidEmail && !password.isEmpty && !isLoading
    }

    /// Submits the credentials.
    func login() async {
        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = LoginRequest(email: email.trimmed, password: password)
            let response = try await authService.login(request)
            try await onAuthenticated(response)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

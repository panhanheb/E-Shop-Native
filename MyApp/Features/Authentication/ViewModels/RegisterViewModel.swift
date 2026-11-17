import Foundation
import Observation

/// Drives the registration screen: form input, validation, and submission.
@Observable
@MainActor
final class RegisterViewModel {
    var name = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    private(set) var isLoading = false
    var errorMessage: String?

    private let authService: any AuthServiceProtocol
    private let onAuthenticated: @MainActor (AuthResponse) async throws -> Void

    /// Creates the view model.
    /// - Parameters:
    ///   - authService: Service used to create the account.
    ///   - onAuthenticated: Called with the response after successful registration.
    init(
        authService: any AuthServiceProtocol,
        onAuthenticated: @escaping @MainActor (AuthResponse) async throws -> Void
    ) {
        self.authService = authService
        self.onAuthenticated = onAuthenticated
    }

    /// The first validation problem with the current input, if any.
    var validationMessage: String? {
        if !email.isEmpty && !email.isValidEmail {
            return String(localized: "Enter a valid email address.")
        }
        if !password.isEmpty && password.count < RegisterRequest.minimumPasswordLength {
            return String(localized: "Password must be at least \(RegisterRequest.minimumPasswordLength) characters.")
        }
        if !confirmPassword.isEmpty && password != confirmPassword {
            return String(localized: "Passwords do not match.")
        }
        return nil
    }

    /// Whether every field is valid and the form can be submitted.
    var canSubmit: Bool {
        !name.trimmed.isEmpty
            && email.isValidEmail
            && password.count >= RegisterRequest.minimumPasswordLength
            && password == confirmPassword
            && !isLoading
    }

    /// Creates the account.
    func register() async {
        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = RegisterRequest(name: name.trimmed, email: email.trimmed, password: password)
            let response = try await authService.register(request)
            try await onAuthenticated(response)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

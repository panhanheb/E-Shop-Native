import Foundation

/// Domain errors returned by authentication services.
enum AuthError: Error, Equatable, Sendable {
    case invalidCredentials
    case emailAlreadyInUse
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            String(localized: "Incorrect email or password.")
        case .emailAlreadyInUse:
            String(localized: "An account with this email already exists.")
        }
    }
}

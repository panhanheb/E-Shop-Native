import Foundation

/// Errors thrown by `KeychainTokenStore`.
enum KeychainError: Error, Equatable, Sendable {
    case unexpectedStatus(OSStatus)
}

extension KeychainError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unexpectedStatus(let status):
            String(localized: "Secure storage failed (code \(Int(status))).")
        }
    }
}

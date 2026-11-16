import Foundation

/// Non-persistent token store used by mock mode, previews, and tests.
actor InMemoryTokenStore: TokenStoreProtocol {
    private var storedToken: String?

    /// Creates a store, optionally pre-populated with `token`.
    init(token: String? = nil) {
        storedToken = token
    }

    func token() -> String? {
        storedToken
    }

    func save(_ token: String) {
        storedToken = token
    }

    func clear() {
        storedToken = nil
    }
}

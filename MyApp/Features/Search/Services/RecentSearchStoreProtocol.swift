import Foundation

/// Loads and saves the customer's recent search terms, newest first.
@MainActor
protocol RecentSearchStoreProtocol: AnyObject {
    /// Saved terms, newest first.
    func load() -> [String]

    /// Replaces the saved terms.
    func save(_ searches: [String])
}

/// `UserDefaults`-backed recent searches, so they survive app launches.
final class RecentSearchStore: RecentSearchStoreProtocol {
    private let defaults: UserDefaults
    private let key: String

    /// Creates the store.
    /// - Parameters:
    ///   - defaults: Store to read and write.
    ///   - key: Key the terms are saved under.
    init(defaults: UserDefaults = .standard, key: String = "search.recent") {
        self.defaults = defaults
        self.key = key
    }

    func load() -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    func save(_ searches: [String]) {
        defaults.set(searches, forKey: key)
    }
}

/// In-memory recent searches for previews, UI tests, and unit tests.
final class InMemoryRecentSearchStore: RecentSearchStoreProtocol {
    private var searches: [String]

    /// Creates the store with optional starting terms.
    init(searches: [String] = []) {
        self.searches = searches
    }

    func load() -> [String] {
        searches
    }

    func save(_ searches: [String]) {
        self.searches = searches
    }
}

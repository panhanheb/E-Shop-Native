import Foundation
import Observation

/// State for the Search screen: recent searches and the category / on-sale filters.
///
/// The query text, sort order, and text matching come from the shared `ProductListViewModel`;
/// this view model narrows those results and remembers what the customer searched for.
@Observable
@MainActor
final class SearchViewModel {
    /// Most recent searches kept.
    static let maxRecentSearches = 8

    /// Saved search terms, newest first.
    private(set) var recentSearches: [String]
    /// Only show products in this category, or all when `nil`.
    var selectedCategory: ProductCategory?
    /// Only show discounted products.
    var isOnSaleOnly = false

    private let store: any RecentSearchStoreProtocol

    /// Creates the view model and loads saved searches.
    init(store: any RecentSearchStoreProtocol) {
        self.store = store
        self.recentSearches = store.load()
    }

    // MARK: Filtering

    /// `products` narrowed to the selected category and, if set, to items on sale. Order is kept.
    func filter(_ products: [Product]) -> [Product] {
        products.filter { product in
            let matchesCategory = selectedCategory.map { product.category == $0 } ?? true
            let isOnSale = product.originalPrice.map { $0 > product.price } ?? false
            return matchesCategory && (!isOnSaleOnly || isOnSale)
        }
    }

    /// Selects `category`, or clears the selection if it's already selected.
    func toggleCategory(_ category: ProductCategory) {
        selectedCategory = selectedCategory == category ? nil : category
    }

    // MARK: Recent searches

    /// Recent searches containing `query` (all of them when `query` is blank).
    func recentSearches(matching query: String) -> [String] {
        let query = query.trimmed
        guard !query.isEmpty else { return recentSearches }
        return recentSearches.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    /// Saves `query` as the newest recent search. Blank queries are ignored, and an existing
    /// entry (compared case-insensitively) moves to the top instead of being duplicated.
    func record(_ query: String) {
        let query = query.trimmed
        guard !query.isEmpty else { return }

        var searches = recentSearches.filter { $0.caseInsensitiveCompare(query) != .orderedSame }
        searches.insert(query, at: 0)
        updateRecentSearches(Array(searches.prefix(Self.maxRecentSearches)))
    }

    /// Removes one recent search.
    func removeRecentSearch(_ search: String) {
        updateRecentSearches(recentSearches.filter { $0 != search })
    }

    /// Removes every recent search.
    func clearRecentSearches() {
        updateRecentSearches([])
    }

    private func updateRecentSearches(_ searches: [String]) {
        recentSearches = searches
        store.save(searches)
    }
}

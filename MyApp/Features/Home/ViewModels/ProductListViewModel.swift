import Foundation
import Observation

/// State and actions for the catalog: loading, category filter, search, and sort.
@Observable
@MainActor
final class ProductListViewModel {
    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    var errorMessage: String?
    var searchText = ""
    /// Selected category, or `nil` for all categories.
    var selectedCategory: ProductCategory?
    var sort: ProductSort = .featured

    private let productService: any ProductServiceProtocol

    /// Creates the view model.
    init(productService: any ProductServiceProtocol) {
        self.productService = productService
    }

    /// Products matching the selected category and search text, in the chosen sort order.
    var visibleProducts: [Product] {
        let query = searchText.trimmed
        let filtered = products.filter { product in
            let matchesCategory = selectedCategory == nil || product.category == selectedCategory
            let matchesQuery = query.isEmpty
                || product.name.localizedCaseInsensitiveContains(query)
                || product.details.localizedCaseInsensitiveContains(query)
            return matchesCategory && matchesQuery
        }

        switch sort {
        case .featured:
            return filtered
        case .priceLowToHigh:
            return filtered.sorted { $0.price < $1.price }
        case .priceHighToLow:
            return filtered.sorted { $0.price > $1.price }
        case .topRated:
            return filtered.sorted { $0.rating > $1.rating }
        }
    }

    /// Whether an error occurred after the first load (shown as an alert over the catalog).
    var isErrorAlertPresented: Bool {
        get { errorMessage != nil && hasLoaded }
        set { if !newValue { errorMessage = nil } }
    }

    /// Loads the catalog the first time the screen appears.
    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await loadProducts()
    }

    /// Fetches the catalog, replacing the current list.
    func loadProducts() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            products = try await productService.fetchProducts()
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Selects `category`, or clears the filter when it is already selected.
    func toggleCategory(_ category: ProductCategory) {
        selectedCategory = selectedCategory == category ? nil : category
    }
}

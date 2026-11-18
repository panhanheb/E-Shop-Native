import Foundation
import Observation

/// The product catalog: loading, search, sort, and the groups shown on Home (best sellers, offers, categories).
///
/// One shared instance lives in `DependencyContainer`, so Home, Categories, and every product list
/// use the same loaded catalog.
@Observable
@MainActor
final class ProductListViewModel {
    /// Number of products shown in the Home "Best Sellers" row.
    static let bestSellerLimit = 8

    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    var errorMessage: String?
    var searchText = ""
    var sort: ProductSort = .featured

    private let productService: any ProductServiceProtocol

    /// Creates the view model.
    init(productService: any ProductServiceProtocol) {
        self.productService = productService
    }

    // MARK: Derived lists

    /// Most-reviewed products, for the Home "Best Sellers" row.
    var bestSellers: [Product] {
        Array(products.sorted { $0.reviewCount > $1.reviewCount }.prefix(Self.bestSellerLimit))
    }

    /// Products currently discounted.
    var offers: [Product] {
        products.filter { product in
            guard let originalPrice = product.originalPrice else { return false }
            return originalPrice > product.price
        }
    }

    /// Largest discount across all offers, as a whole percentage (e.g. 30), or `nil` if nothing is on sale.
    var maxDiscountPercent: Int? {
        let percents = offers.compactMap { product -> Int? in
            guard let originalPrice = product.originalPrice, originalPrice > 0 else { return nil }
            let fraction = (originalPrice - product.price) / originalPrice * 100
            return Int(NSDecimalNumber(decimal: fraction).doubleValue.rounded())
        }
        return percents.max()
    }

    /// Whether the user has typed a search query.
    var isSearching: Bool {
        !searchText.trimmed.isEmpty
    }

    /// Products whose name, tagline, or details match the search text, in the chosen sort order.
    var searchResults: [Product] {
        let query = searchText.trimmed
        guard !query.isEmpty else { return [] }
        return sorted(products.filter { product in
            product.name.localizedCaseInsensitiveContains(query)
                || product.tagline.localizedCaseInsensitiveContains(query)
                || product.details.localizedCaseInsensitiveContains(query)
        })
    }

    /// Products in `collection`, in the chosen sort order.
    func products(in collection: ProductCollection) -> [Product] {
        switch collection {
        case .all:
            sorted(products)
        case .bestSellers:
            sort == .featured ? bestSellers : sorted(bestSellers)
        case .offers:
            sorted(offers)
        case .category(let category):
            sorted(products.filter { $0.category == category })
        }
    }

    /// Number of products in `category`.
    func productCount(in category: ProductCategory) -> Int {
        products.filter { $0.category == category }.count
    }

    /// Whether an error occurred after the first load (shown as an alert over the catalog).
    var isErrorAlertPresented: Bool {
        get { errorMessage != nil && hasLoaded }
        set { if !newValue { errorMessage = nil } }
    }

    // MARK: Actions

    /// Loads the catalog the first time any screen needs it.
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

    // MARK: Helpers

    private func sorted(_ list: [Product]) -> [Product] {
        switch sort {
        case .featured:
            list
        case .priceLowToHigh:
            list.sorted { $0.price < $1.price }
        case .priceHighToLow:
            list.sorted { $0.price > $1.price }
        case .topRated:
            list.sorted { $0.rating > $1.rating }
        }
    }
}

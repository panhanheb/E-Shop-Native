import Foundation

/// Reads the product catalog.
protocol ProductServiceProtocol: Sendable {
    /// Returns every product in the catalog, in featured order.
    func fetchProducts() async throws -> [Product]

    /// Returns the latest version of a single product (price and stock may change).
    func fetchProduct(id: Product.ID) async throws -> Product
}

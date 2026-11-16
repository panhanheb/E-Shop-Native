import Foundation

/// In-memory `ProductServiceProtocol` used until the backend is available, and in previews.
final class MockProductService: ProductServiceProtocol {
    private let products: [Product]
    private let latency: Duration

    /// Creates the mock.
    /// - Parameters:
    ///   - products: Catalog to serve.
    ///   - latency: Simulated network delay.
    init(products: [Product] = Product.mocks, latency: Duration = .milliseconds(600)) {
        self.products = products
        self.latency = latency
    }

    func fetchProducts() async throws -> [Product] {
        try await Task.sleep(for: latency)
        return products
    }

    func fetchProduct(id: Product.ID) async throws -> Product {
        try await Task.sleep(for: latency)
        guard let product = products.first(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        return product
    }
}

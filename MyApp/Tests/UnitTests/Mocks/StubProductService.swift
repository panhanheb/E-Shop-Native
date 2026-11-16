import Foundation
@testable import MyApp

/// Configurable `ProductServiceProtocol` that records calls.
@MainActor
final class StubProductService: ProductServiceProtocol {
    var products: [Product]
    var fetchError: (any Error)?

    private(set) var fetchProductsCallCount = 0
    private(set) var fetchedProductIDs: [Product.ID] = []

    init(products: [Product] = Product.mocks) {
        self.products = products
    }

    func fetchProducts() async throws -> [Product] {
        fetchProductsCallCount += 1
        if let fetchError { throw fetchError }
        return products
    }

    func fetchProduct(id: Product.ID) async throws -> Product {
        fetchedProductIDs.append(id)
        if let fetchError { throw fetchError }
        guard let product = products.first(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        return product
    }
}

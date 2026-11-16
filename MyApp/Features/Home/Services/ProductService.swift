import Foundation

/// REST implementation of `ProductServiceProtocol`.
final class ProductService: ProductServiceProtocol {
    private let apiClient: any APIClientProtocol

    /// Creates the service backed by `apiClient`.
    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchProducts() async throws -> [Product] {
        try await apiClient.send(.products, as: [Product].self)
    }

    func fetchProduct(id: Product.ID) async throws -> Product {
        try await apiClient.send(.product(id: id), as: Product.self)
    }
}

import Foundation
import Observation

/// Products the customer has hearted. One shared instance lives in `DependencyContainer`.
@Observable
@MainActor
final class WishlistViewModel {
    /// Saved products, most recently added first.
    private(set) var products: [Product]

    /// Creates the wishlist, optionally pre-filled (previews and tests).
    init(products: [Product] = []) {
        self.products = products
    }

    var count: Int { products.count }

    var isEmpty: Bool { products.isEmpty }

    /// Whether `product` is saved.
    func contains(_ product: Product) -> Bool {
        products.contains { $0.id == product.id }
    }

    /// Saves `product`, or removes it if it is already saved.
    func toggle(_ product: Product) {
        if contains(product) {
            remove(product)
        } else {
            products.insert(product, at: 0)
        }
    }

    func remove(_ product: Product) {
        products.removeAll { $0.id == product.id }
    }

    /// Empties the wishlist (on sign-out).
    func clear() {
        products.removeAll()
    }
}

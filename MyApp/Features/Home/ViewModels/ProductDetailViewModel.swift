import Foundation
import Observation

/// State and actions for a product's detail screen: refresh, quantity, and add to cart.
@Observable
@MainActor
final class ProductDetailViewModel {
    private(set) var product: Product
    private(set) var quantity = 1
    private(set) var isLoading = false
    /// Quantity from the most recent add-to-cart, used in the confirmation message.
    private(set) var lastAddedQuantity = 0
    var errorMessage: String?
    var isAddedConfirmationPresented = false

    private let productService: any ProductServiceProtocol
    private let onAddToCart: @MainActor (Product, Int) -> Void

    /// Creates the view model.
    /// - Parameters:
    ///   - product: The product to show (displayed immediately, then refreshed).
    ///   - productService: Service used to refresh price and stock.
    ///   - onAddToCart: Adds the product and quantity to the cart.
    init(
        product: Product,
        productService: any ProductServiceProtocol,
        onAddToCart: @escaping @MainActor (Product, Int) -> Void
    ) {
        self.product = product
        self.productService = productService
        self.onAddToCart = onAddToCart
    }

    /// Whether any units are available.
    var isInStock: Bool { product.stock > 0 }

    /// Whether the quantity can be lowered.
    var canDecreaseQuantity: Bool { quantity > 1 }

    /// Whether the quantity can be raised without exceeding stock.
    var canIncreaseQuantity: Bool { quantity < product.stock }

    /// Price for the selected quantity.
    var totalPrice: Decimal { product.price * Decimal(quantity) }

    func increaseQuantity() {
        guard canIncreaseQuantity else { return }
        quantity += 1
    }

    func decreaseQuantity() {
        guard canDecreaseQuantity else { return }
        quantity -= 1
    }

    /// Re-fetches the product to pick up price and stock changes.
    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            product = try await productService.fetchProduct(id: product.id)
            quantity = min(quantity, max(product.stock, 1))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Adds the selected quantity to the cart and shows a confirmation.
    func addToCart() {
        guard isInStock else { return }
        onAddToCart(product, quantity)
        lastAddedQuantity = quantity
        quantity = 1
        isAddedConfirmationPresented = true
    }
}

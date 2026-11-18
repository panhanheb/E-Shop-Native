import Foundation
import Observation

/// The shopping cart. One shared instance lives in `DependencyContainer` so every tab sees the same cart.
@Observable
@MainActor
final class CartViewModel {
    private(set) var items: [CartItem]

    /// Creates the cart, optionally pre-filled (previews and tests).
    init(items: [CartItem] = []) {
        self.items = items
    }

    // MARK: Totals

    /// Total number of units across all items (shown on the tab badge).
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var isEmpty: Bool { items.isEmpty }

    var subtotal: Decimal {
        items.reduce(Decimal.zero) { $0 + lineTotal(for: $1) }
    }

    var shippingFee: Decimal {
        ShippingPolicy.fee(forSubtotal: subtotal)
    }

    var total: Decimal {
        subtotal + shippingFee
    }

    /// How much more the customer must spend to get free shipping, or `nil` if it already applies.
    var amountUntilFreeShipping: Decimal? {
        let remaining = ShippingPolicy.freeShippingThreshold - subtotal
        return isEmpty || remaining <= 0 ? nil : remaining
    }

    /// Price of one cart line.
    func lineTotal(for item: CartItem) -> Decimal {
        item.product.price * Decimal(item.quantity)
    }

    /// Whether another unit of `item` can be added without exceeding stock.
    func canIncrement(_ item: CartItem) -> Bool {
        item.quantity < item.product.stock
    }

    // MARK: Changes

    /// Adds `quantity` units of `product`, merging with an existing line and capping at stock.
    func add(_ product: Product, quantity: Int = 1) {
        guard quantity > 0, product.stock > 0 else { return }

        if let index = items.firstIndex(where: { $0.id == product.id }) {
            items[index].product = product
            items[index].quantity = min(items[index].quantity + quantity, product.stock)
        } else {
            items.append(CartItem(product: product, quantity: min(quantity, product.stock)))
        }
    }

    func increment(_ item: CartItem) {
        setQuantity(item.quantity + 1, for: item)
    }

    /// Lowers the quantity by one, removing the line when it reaches zero.
    func decrement(_ item: CartItem) {
        setQuantity(item.quantity - 1, for: item)
    }

    /// Sets the quantity for `item`; zero or less removes it, and the value is capped at stock.
    func setQuantity(_ quantity: Int, for item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = min(quantity, items[index].product.stock)
        }
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    /// Empties the cart (after checkout or sign-out).
    func clear() {
        items.removeAll()
    }
}

import Foundation
import Observation

/// Delivery details, payment choice, and order placement for checkout.
@Observable
@MainActor
final class CheckoutViewModel {
    var fullName: String
    var phone = ""
    var street = ""
    var city = ""
    var paymentMethod: PaymentMethod = .cashOnDelivery
    private(set) var isPlacingOrder = false
    /// Set once the order is placed; the view then shows the confirmation.
    private(set) var placedOrder: Order?
    var errorMessage: String?

    /// The cart contents being checked out.
    let items: [CartItem]

    private let orderService: any OrderServiceProtocol
    private let onOrderPlaced: @MainActor (Order) -> Void

    /// Creates the view model.
    /// - Parameters:
    ///   - items: Cart contents to order.
    ///   - fullName: Pre-filled recipient name (usually the signed-in user's name).
    ///   - orderService: Service used to place the order.
    ///   - onOrderPlaced: Called with the new order (e.g. to clear the cart).
    init(
        items: [CartItem],
        fullName: String,
        orderService: any OrderServiceProtocol,
        onOrderPlaced: @escaping @MainActor (Order) -> Void
    ) {
        self.items = items
        self.fullName = fullName
        self.orderService = orderService
        self.onOrderPlaced = onOrderPlaced
    }

    // MARK: Totals

    var subtotal: Decimal {
        items.reduce(Decimal.zero) { $0 + $1.product.price * Decimal($1.quantity) }
    }

    var shippingFee: Decimal {
        ShippingPolicy.fee(forSubtotal: subtotal)
    }

    var total: Decimal {
        subtotal + shippingFee
    }

    // MARK: Validation

    /// The first problem with the entered details, if any.
    var validationMessage: String? {
        if !phone.isEmpty && !phone.isValidPhoneNumber {
            return String(localized: "Enter a valid phone number.")
        }
        return nil
    }

    /// Whether all required fields are valid and an order can be placed.
    var canPlaceOrder: Bool {
        !items.isEmpty
            && !fullName.trimmed.isEmpty
            && phone.isValidPhoneNumber
            && !street.trimmed.isEmpty
            && !city.trimmed.isEmpty
            && !isPlacingOrder
            && placedOrder == nil
    }

    // MARK: Actions

    /// Sends the order to the server.
    func placeOrder() async {
        guard canPlaceOrder else { return }

        isPlacingOrder = true
        errorMessage = nil
        defer { isPlacingOrder = false }

        let request = PlaceOrderRequest(
            items: items.map {
                OrderItem(productID: $0.product.id, name: $0.product.name, unitPrice: $0.product.price, quantity: $0.quantity)
            },
            shippingAddress: ShippingAddress(
                fullName: fullName.trimmed,
                phone: phone.trimmed,
                street: street.trimmed,
                city: city.trimmed
            ),
            paymentMethod: paymentMethod
        )

        do {
            let order = try await orderService.placeOrder(request)
            placedOrder = order
            onOrderPlaced(order)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

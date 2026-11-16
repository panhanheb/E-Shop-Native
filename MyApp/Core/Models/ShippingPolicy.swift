import Foundation

/// Shipping fee rules shared by the cart, checkout, and mock order service.
enum ShippingPolicy {
    /// Orders at or above this subtotal ship for free.
    static let freeShippingThreshold: Decimal = 50
    /// Fee charged below the threshold.
    static let flatFee: Decimal = 2.5

    /// The shipping fee for a cart with the given subtotal.
    static func fee(forSubtotal subtotal: Decimal) -> Decimal {
        subtotal <= 0 || subtotal >= freeShippingThreshold ? 0 : flatFee
    }
}

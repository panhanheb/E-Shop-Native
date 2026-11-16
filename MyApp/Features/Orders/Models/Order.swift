import Foundation

/// A placed order. Totals are calculated by the server.
struct Order: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    /// Human-readable order number, e.g. `"MA-100245"`.
    let number: String
    let items: [OrderItem]
    let subtotal: Decimal
    let shippingFee: Decimal
    let total: Decimal
    var status: OrderStatus
    let shippingAddress: ShippingAddress
    let paymentMethod: PaymentMethod
    let createdAt: Date
}

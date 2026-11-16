import Foundation

/// Body sent to the server to place an order.
struct PlaceOrderRequest: Codable, Equatable, Sendable {
    let items: [OrderItem]
    let shippingAddress: ShippingAddress
    let paymentMethod: PaymentMethod
}

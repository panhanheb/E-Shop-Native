import Foundation
@testable import MyApp

/// Configurable `OrderServiceProtocol` that records calls.
@MainActor
final class StubOrderService: OrderServiceProtocol {
    var orders: [Order] = Order.mocks
    var fetchError: (any Error)?
    var placeOrderError: (any Error)?

    private(set) var placedRequests: [PlaceOrderRequest] = []

    func fetchOrders() async throws -> [Order] {
        if let fetchError { throw fetchError }
        return orders
    }

    func placeOrder(_ request: PlaceOrderRequest) async throws -> Order {
        placedRequests.append(request)
        if let placeOrderError { throw placeOrderError }
        let subtotal = request.items.reduce(Decimal.zero) { $0 + $1.unitPrice * Decimal($1.quantity) }
        let fee = ShippingPolicy.fee(forSubtotal: subtotal)
        let order = Order(
            id: UUID(),
            number: "MA-TEST",
            items: request.items,
            subtotal: subtotal,
            shippingFee: fee,
            total: subtotal + fee,
            status: .pending,
            shippingAddress: request.shippingAddress,
            paymentMethod: request.paymentMethod,
            createdAt: .now
        )
        orders.insert(order, at: 0)
        return order
    }
}

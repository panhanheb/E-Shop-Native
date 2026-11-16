import Foundation

/// Places orders and reads the signed-in user's order history.
protocol OrderServiceProtocol: Sendable {
    /// Returns the user's orders, newest first.
    func fetchOrders() async throws -> [Order]

    /// Places an order and returns it with server-calculated totals.
    func placeOrder(_ request: PlaceOrderRequest) async throws -> Order
}

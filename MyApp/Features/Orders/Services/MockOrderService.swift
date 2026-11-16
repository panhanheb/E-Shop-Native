import Foundation

/// In-memory `OrderServiceProtocol` used until the backend is available, and in previews.
actor MockOrderService: OrderServiceProtocol {
    private var orders: [Order]
    private var nextOrderNumber = 100_246
    private let latency: Duration

    /// Creates the mock.
    /// - Parameters:
    ///   - orders: Initial order history.
    ///   - latency: Simulated network delay.
    init(orders: [Order] = Order.mocks, latency: Duration = .milliseconds(600)) {
        self.orders = orders
        self.latency = latency
    }

    func fetchOrders() async throws -> [Order] {
        try await Task.sleep(for: latency)
        return orders.sorted { $0.createdAt > $1.createdAt }
    }

    func placeOrder(_ request: PlaceOrderRequest) async throws -> Order {
        try await Task.sleep(for: latency)
        guard !request.items.isEmpty else {
            throw NetworkError.server(statusCode: 422)
        }

        let subtotal = request.items.reduce(Decimal.zero) { $0 + $1.unitPrice * Decimal($1.quantity) }
        let shippingFee = ShippingPolicy.fee(forSubtotal: subtotal)
        let order = Order(
            id: UUID(),
            number: "MA-\(nextOrderNumber)",
            items: request.items,
            subtotal: subtotal,
            shippingFee: shippingFee,
            total: subtotal + shippingFee,
            status: .pending,
            shippingAddress: request.shippingAddress,
            paymentMethod: request.paymentMethod,
            createdAt: .now
        )
        nextOrderNumber += 1
        orders.insert(order, at: 0)
        return order
    }
}

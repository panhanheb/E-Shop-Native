import Foundation

/// REST implementation of `OrderServiceProtocol`.
final class OrderService: OrderServiceProtocol {
    private let apiClient: any APIClientProtocol

    /// Creates the service backed by `apiClient`.
    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchOrders() async throws -> [Order] {
        try await apiClient.send(.orders, as: [Order].self)
    }

    func placeOrder(_ request: PlaceOrderRequest) async throws -> Order {
        try await apiClient.send(Endpoint.placeOrder(request), as: Order.self)
    }
}

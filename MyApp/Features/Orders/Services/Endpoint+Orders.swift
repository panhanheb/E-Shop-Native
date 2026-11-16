import Foundation

extension Endpoint {
    /// `GET /orders`
    static let orders = Endpoint(path: AppEndPoint.orders)

    /// `POST /orders`
    static func placeOrder(_ request: PlaceOrderRequest) throws -> Endpoint {
        try Endpoint(path: AppEndPoint.orders, method: .post, body: request)
    }
}

import Foundation

extension Endpoint {
    /// `GET /products`
    static let products = Endpoint(path: AppEndPoint.products, requiresAuthentication: false)

    /// `GET /products/{id}`
    static func product(id: Product.ID) -> Endpoint {
        Endpoint(path: AppEndPoint.product(id: id), requiresAuthentication: false)
    }
}

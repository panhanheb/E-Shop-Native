import Foundation

/// Every REST path the app calls, relative to `AppEnvironment.baseURL`.
///
/// Endpoints are built from these in the `Endpoint+<Feature>.swift` files.
enum AppEndPoint {
    // MARK: Auth

    static let login = "auth/login"
    static let register = "auth/register"
    static let logout = "auth/logout"

    // MARK: Profile

    static let profile = "me"

    // MARK: Products

    static let products = "products"

    /// `products/{id}`
    static func product(id: UUID) -> String {
        "\(products)/\(id.uuidString)"
    }

    // MARK: Orders

    static let orders = "orders"
}

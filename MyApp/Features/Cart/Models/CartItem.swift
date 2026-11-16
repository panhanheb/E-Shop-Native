import Foundation

/// A product in the cart and how many units the customer wants.
struct CartItem: Codable, Identifiable, Equatable, Hashable, Sendable {
    var product: Product
    var quantity: Int

    var id: Product.ID { product.id }
}

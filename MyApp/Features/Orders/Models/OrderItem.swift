import Foundation

/// A product line in an order, with the price captured at purchase time.
struct OrderItem: Codable, Identifiable, Equatable, Hashable, Sendable {
    let productID: UUID
    let name: String
    let unitPrice: Decimal
    let quantity: Int

    var id: UUID { productID }
}

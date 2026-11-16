import Foundation

/// An item for sale in the catalog.
struct Product: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    var name: String
    /// Short benefit line shown under the name on cards, e.g. "Brightening & Glow".
    var tagline: String
    var details: String
    /// Current selling price in `AppCurrency.code`.
    var price: Decimal
    /// Price before discount, if the product is on sale.
    var originalPrice: Decimal?
    var category: ProductCategory
    var imageURL: URL?
    /// Average review score from 0 to 5.
    var rating: Double
    var reviewCount: Int
    /// Units available to order.
    var stock: Int
}

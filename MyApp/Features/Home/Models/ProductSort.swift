import Foundation

/// Sort orders available in the catalog.
enum ProductSort: String, CaseIterable, Identifiable, Sendable {
    case featured
    case priceLowToHigh
    case priceHighToLow
    case topRated

    var id: Self { self }
}

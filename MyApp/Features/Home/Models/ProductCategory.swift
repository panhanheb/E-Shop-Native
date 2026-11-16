import Foundation

/// Top-level grouping of beauty products in the catalog.
enum ProductCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case skincare
    case makeup
    case fragrance
    case haircare
    case tools

    var id: Self { self }
}

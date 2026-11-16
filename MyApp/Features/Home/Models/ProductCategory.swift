import Foundation

/// Top-level grouping of products in the catalog.
enum ProductCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case electronics
    case fashion
    case home
    case beauty
    case sports

    var id: Self { self }
}

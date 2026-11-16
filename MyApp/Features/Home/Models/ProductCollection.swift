import Foundation

/// A named group of products that can be opened as its own screen ("View All", a category, offers).
enum ProductCollection: Hashable, Sendable {
    case all
    case bestSellers
    case offers
    case category(ProductCategory)
}

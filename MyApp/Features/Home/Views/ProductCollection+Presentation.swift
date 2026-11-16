import SwiftUI

extension ProductCollection {
    /// Screen title for the collection.
    var title: LocalizedStringKey {
        switch self {
        case .all: "All Products"
        case .bestSellers: "Best Sellers"
        case .offers: "Special Offers"
        case .category(let category): category.title
        }
    }
}

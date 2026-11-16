import SwiftUI

extension ProductSort {
    /// Localized display name.
    var title: LocalizedStringKey {
        switch self {
        case .featured: "Featured"
        case .priceLowToHigh: "Price: Low to High"
        case .priceHighToLow: "Price: High to Low"
        case .topRated: "Top Rated"
        }
    }
}

import SwiftUI

/// Slides in the Home hero carousel. Replace with server-driven banners when the API supports them.
enum HomePromotion: Int, CaseIterable, Identifiable {
    case newArrivals
    case bestSellers
    case offers

    var id: Self { self }

    var tag: LocalizedStringKey {
        switch self {
        case .newArrivals: "NEW ARRIVALS"
        case .bestSellers: "BEST SELLERS"
        case .offers: "LIMITED TIME"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .newArrivals: "Glow Naturally, Shine Beautifully"
        case .bestSellers: "Loved by Thousands"
        case .offers: "Treat Yourself Today"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .newArrivals: "Explore our premium beauty collection for radiant you."
        case .bestSellers: "Discover the favorites everyone is talking about."
        case .offers: "Exclusive savings on skincare and makeup essentials."
        }
    }

    /// Where "Shop Now" goes.
    var destination: ProductCollection {
        switch self {
        case .newArrivals: .all
        case .bestSellers: .bestSellers
        case .offers: .offers
        }
    }
}

extension HomePromotion {
    /// Banner background, from top-leading to bottom-trailing.
    var gradient: [Color] {
        switch self {
        case .newArrivals: [AppColors.primary, Color(hex: 0x8E0F17)]
        case .bestSellers: [Color(hex: 0x2B2F36), Color(hex: 0x111317)]
        case .offers: [AppColors.accentPink, Color(hex: 0x9E1F4E)]
        }
    }
}

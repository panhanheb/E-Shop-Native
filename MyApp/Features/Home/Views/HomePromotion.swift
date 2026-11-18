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
    /// Accent for the banner's tint, tag, and button.
    var accent: Color {
        switch self {
        case .newArrivals: AppColors.primary
        case .bestSellers: AppColors.accentAmber
        case .offers: AppColors.accentPink
        }
    }
}

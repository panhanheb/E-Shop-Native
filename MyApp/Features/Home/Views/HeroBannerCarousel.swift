import SwiftUI

/// Swipeable promotion banners with page dots. Advances automatically every few seconds.
struct HeroBannerCarousel: View {
    /// Called with the promotion's destination when "Shop Now" is tapped.
    let onShopNow: (ProductCollection) -> Void

    @State private var selection: HomePromotion = .newArrivals

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            TabView(selection: $selection) {
                ForEach(HomePromotion.allCases) { promotion in
                    HeroBannerView(promotion: promotion) {
                        onShopNow(promotion.destination)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .tag(promotion)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 190)

            PageDots(count: HomePromotion.allCases.count, current: selection.rawValue)
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                guard !Task.isCancelled else { return }
                let nextIndex = (selection.rawValue + 1) % HomePromotion.allCases.count
                withAnimation(.easeInOut) {
                    selection = HomePromotion(rawValue: nextIndex) ?? .newArrivals
                }
            }
        }
    }
}

#Preview {
    HeroBannerCarousel { _ in }
        .background(AppColors.background)
}

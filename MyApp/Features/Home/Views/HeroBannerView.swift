import SwiftUI

/// A single hero banner: tag, serif headline, subtitle, Shop Now button, and artwork.
struct HeroBannerView: View {
    let promotion: HomePromotion
    let onShopNow: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: AppRadius.xLarge)
                .fill(
                    LinearGradient(
                        colors: [AppColors.blush.opacity(0.6), AppColors.blush],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            BeautyArtworkView(scale: 0.95)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(promotion.tag)
                    .font(.system(size: 10, weight: .semibold))
                    .kerning(0.5)
                    .foregroundStyle(AppColors.primary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppColors.surface.opacity(0.85), in: Capsule())

                Text(promotion.title)
                    .font(AppFont.display)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(promotion.subtitle)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                ArrowPillButton(title: "Shop Now", action: onShopNow)
                    .padding(.top, AppSpacing.xs)
                    .accessibilityIdentifier("home.shopNow")
            }
            .frame(maxWidth: 190, alignment: .leading)
            .padding(AppSpacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xLarge))
    }
}

#Preview {
    VStack {
        ForEach(HomePromotion.allCases) { promotion in
            HeroBannerView(promotion: promotion) {}
                .frame(height: 220)
        }
    }
    .padding()
}

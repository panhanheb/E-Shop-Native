import SwiftUI

/// A single hero banner: tag, headline, subtitle, Shop Now button, and artwork on a bold gradient.
struct HeroBannerView: View {
    let promotion: HomePromotion
    let onShopNow: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: promotion.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Soft glow behind the artwork.
            Circle()
                .fill(.white.opacity(0.12))
                .frame(width: 220, height: 220)
                .offset(x: 120, y: 30)
                .frame(maxWidth: .infinity, alignment: .trailing)

            BeautyArtworkView(scale: 0.9)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(promotion.tag)
                    .font(.system(size: 10, weight: .bold))
                    .kerning(0.8)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(.white.opacity(0.2), in: Capsule())

                Text(promotion.title)
                    .font(AppFont.display)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(promotion.subtitle)
                    .font(AppFont.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)

                ArrowPillButton(title: "Shop Now", action: onShopNow)
                    .padding(.top, AppSpacing.xs)
                    .accessibilityIdentifier("home.shopNow")
            }
            .frame(maxWidth: 200, alignment: .leading)
            .padding(AppSpacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xLarge, style: .continuous))
    }
}

#Preview {
    VStack {
        ForEach(HomePromotion.allCases) { promotion in
            HeroBannerView(promotion: promotion) {}
                .frame(height: 200)
        }
    }
    .padding()
}

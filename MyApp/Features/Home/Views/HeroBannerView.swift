import SwiftUI

/// A single hero banner: tag, headline, subtitle, and a Shop Now button on a soft tinted card,
/// with product artwork on the right.
struct HeroBannerView: View {
    let promotion: HomePromotion
    let onShopNow: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [promotion.accent.opacity(0.10), promotion.accent.opacity(0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .background(AppColors.surface)

            BeautyArtworkView(scale: 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)

            VStack(alignment: .leading, spacing: AppSpacing.xs + AppSpacing.xxs) {
                Text(promotion.tag)
                    .font(.system(size: 11, weight: .bold))
                    .kerning(0.6)
                    .foregroundStyle(promotion.accent)

                Text(promotion.title)
                    .font(AppFont.sectionTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(promotion.subtitle)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)

                Button(action: onShopNow) {
                    Text("Shop Now")
                        .font(AppFont.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.onPrimary)
                        .padding(.horizontal, AppSpacing.md + AppSpacing.xs)
                        .frame(height: 36)
                        .background(promotion.accent, in: Capsule())
                }
                .buttonStyle(.pressable)
                .padding(.top, AppSpacing.xs)
                .accessibilityIdentifier("home.shopNow")
            }
            .frame(maxWidth: 190, alignment: .leading)
            .padding(AppSpacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xLarge, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.xLarge, style: .continuous)
                .strokeBorder(AppColors.hairline, lineWidth: 0.5)
        }
    }
}

#Preview {
    VStack {
        ForEach(HomePromotion.allCases) { promotion in
            HeroBannerView(promotion: promotion) {}
                .frame(height: 190)
        }
    }
    .padding()
}

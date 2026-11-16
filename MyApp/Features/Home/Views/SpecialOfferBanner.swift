import SwiftUI

/// "Special Offer — Up to 30% Off" banner with a Grab Now button and a discount badge.
struct SpecialOfferBanner: View {
    /// Largest discount available, as a whole percentage.
    let discountPercent: Int
    let onGrabNow: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.xLarge)
                .fill(
                    LinearGradient(
                        colors: [AppColors.blush, AppColors.blush.opacity(0.55)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Special Offer")
                        .font(AppFont.caption.weight(.semibold))
                        .foregroundStyle(AppColors.primary)
                    Text("Up to \(discountPercent)% Off")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("On selected beauty essentials")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    ArrowPillButton(title: "Grab Now", action: onGrabNow)
                        .padding(.top, AppSpacing.sm)
                        .accessibilityIdentifier("home.grabNow")
                }

                Spacer(minLength: AppSpacing.sm)

                ZStack(alignment: .bottomTrailing) {
                    // Decorative makeup tools
                    HStack(spacing: -6) {
                        Image(systemName: AppImages.categoryMakeup)
                            .rotationEffect(.degrees(-30))
                        Image(systemName: AppImages.categoryTools)
                            .rotationEffect(.degrees(15))
                    }
                    .font(.system(size: 34))
                    .foregroundStyle(AppColors.secondary.gradient)
                    .padding(.trailing, 40)
                    .padding(.bottom, 36)

                    discountBadge
                }
                .accessibilityHidden(true)
            }
            .padding(AppSpacing.lg)
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xLarge))
    }

    private var discountBadge: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(discountPercent, format: .number)
                    .font(.system(size: 24, weight: .bold))
                Text(verbatim: "%")
                    .font(.system(size: 13, weight: .bold))
            }
            Text("OFF")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundStyle(AppColors.primary)
        .frame(width: 72, height: 72)
        .background(AppColors.surface, in: Circle())
        .shadow(color: AppColors.shadow, radius: 6, y: 2)
    }
}

#Preview {
    SpecialOfferBanner(discountPercent: 30) {}
        .padding()
        .background(AppColors.background)
}

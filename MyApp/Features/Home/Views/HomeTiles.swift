import SwiftUI

/// Small square product tile for the two-row "Top Picks" grid.
struct TopPickTile: View {
    let product: Product

    var body: some View {
        ProductImageView(product: product, iconSize: 30)
            .frame(width: 76, height: 76)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .strokeBorder(AppColors.border.opacity(0.4), lineWidth: 0.5)
            }
            .background(AppColors.surface, in: RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
            .shadow(color: AppColors.shadow, radius: 4, y: 2)
            .accessibilityElement()
            .accessibilityLabel(Text(product.name))
    }
}

/// Featured category card: a round icon "plate" sitting on top of a brand-colored card
/// with the category name and a short tagline.
struct FeaturedCategoryCard: View {
    let category: ProductCategory

    private static let plateSize: CGFloat = 96

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Spacer(minLength: 0)
                Text(category.title)
                    .font(AppFont.headline.weight(.bold))
                    .lineLimit(1)
                Text(category.featureTagline)
                    .font(AppFont.caption)
                    .opacity(0.9)
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.sm + AppSpacing.xs)
            .frame(height: 120)
            .background(AppColors.primary.gradient, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .padding(.top, Self.plateSize / 2)

            Circle()
                .fill(AppColors.surface)
                .frame(width: Self.plateSize, height: Self.plateSize)
                .overlay {
                    Image(systemName: category.systemImage)
                        .font(.system(size: 40))
                        .foregroundStyle(category.tint.gradient)
                }
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                .accessibilityHidden(true)
        }
        .frame(width: 160)
        .accessibilityElement(children: .combine)
    }
}

/// Square discounted-product tile for the two-row "Special Offers" grid.
struct SpecialOfferTile: View {
    let product: Product

    private var discountPercent: Int? {
        guard let originalPrice = product.originalPrice, originalPrice > product.price, originalPrice > 0 else { return nil }
        let fraction = (originalPrice - product.price) / originalPrice * 100
        return Int(NSDecimalNumber(decimal: fraction).doubleValue.rounded())
    }

    var body: some View {
        ProductImageView(product: product, iconSize: 40)
            .frame(width: 116, height: 116)
            .overlay(alignment: .bottom) {
                Text(product.price, format: .currency(code: AppCurrency.code))
                    .font(AppFont.captionEmphasized)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppColors.primary)
            }
            .overlay(alignment: .topLeading) {
                if let discountPercent {
                    Text("\(discountPercent)% OFF")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xxs + 1)
                        .background(AppColors.primary, in: Capsule())
                        .padding(AppSpacing.xs + AppSpacing.xxs)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
            .shadow(color: AppColors.shadow, radius: 4, y: 2)
            .accessibilityElement()
            .accessibilityLabel(Text(product.name))
            .accessibilityValue(Text(product.price, format: .currency(code: AppCurrency.code)))
    }
}

/// Brightly colored coupon card showing a discount code. Tapping it copies the code.
struct DiscountCodeCard: View {
    let discountCode: DiscountCode

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(discountCode.headline)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(discountCode.caption)
                .font(AppFont.caption.weight(.medium))
                .lineLimit(2, reservesSpace: true)
                .opacity(0.9)
            Spacer(minLength: 0)
            Text(verbatim: discountCode.code)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .overlay(Capsule().strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3, 2])))
        }
        .foregroundStyle(discountCode.style.foreground)
        .padding(AppSpacing.sm + AppSpacing.xs)
        .frame(width: 128, height: 150, alignment: .leading)
        .background(discountCode.style.background, in: RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
        .shadow(color: AppColors.shadow, radius: 4, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("Copies the code"))
    }
}

/// Wide "What's new?" banner promoting free delivery.
struct WhatsNewBanner: View {
    let onShopNow: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Free Delivery")
                    .font(.title2.weight(.heavy))
                Text("On every order from \(ShippingPolicy.freeShippingThreshold, format: .currency(code: AppCurrency.code))")
                    .font(AppFont.callout)
                    .opacity(0.9)
                ArrowPillButton(title: "Shop Now", action: onShopNow)
                    .padding(.top, AppSpacing.sm)
            }
            .foregroundStyle(.white)

            Spacer(minLength: 0)

            Image(systemName: AppImages.orders)
                .font(.system(size: 64))
                .foregroundStyle(.white.opacity(0.9))
                .rotationEffect(.degrees(-10))
                .accessibilityHidden(true)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 170)
        .background {
            HomeHeaderBackground()
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.xLarge, style: .continuous))
        }
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack { ForEach(Product.mocks.prefix(4)) { TopPickTile(product: $0) } }
            HStack { FeaturedCategoryCard(category: .skincare); FeaturedCategoryCard(category: .makeup) }
            HStack { ForEach(Product.mocks.prefix(3)) { SpecialOfferTile(product: $0) } }
            HStack { ForEach(DiscountCode.featured.prefix(3)) { DiscountCodeCard(discountCode: $0) } }
            WhatsNewBanner {}
        }
        .padding()
    }
    .background(AppColors.background)
}

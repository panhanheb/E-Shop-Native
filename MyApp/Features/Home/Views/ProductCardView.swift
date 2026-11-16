import SwiftUI

/// Product card: image with wishlist heart, name, tagline, stars, price, and a round add button.
struct ProductCardView: View {
    let product: Product
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onAddToCart: () -> Void

    private var isInStock: Bool { product.stock > 0 }

    private var discountPercent: Int? {
        guard let originalPrice = product.originalPrice, originalPrice > product.price, originalPrice > 0 else { return nil }
        let fraction = (originalPrice - product.price) / originalPrice * 100
        return Int(NSDecimalNumber(decimal: fraction).doubleValue.rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            ProductImageView(product: product, iconSize: AppFontSize.iconLarge * 0.7)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
                .overlay(alignment: .topTrailing) { favoriteButton }
                .overlay(alignment: .topLeading) { cornerBadge }
                .padding(.bottom, AppSpacing.xs)

            Text(product.name)
                .font(AppFont.callout.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)

            Text(product.tagline)
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)

            RatingView(rating: product.rating, reviewCount: product.reviewCount)

            HStack(alignment: .center) {
                Text(product.price, format: .currency(code: AppCurrency.code))
                    .font(AppFont.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer(minLength: AppSpacing.xs)
                addButton
            }
            .padding(.top, AppSpacing.xxs)
        }
        .padding(AppSpacing.sm)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: AppRadius.large))
        .shadow(color: AppColors.shadow, radius: 8, y: 3)
        .opacity(isInStock ? 1 : 0.65)
    }

    private var favoriteButton: some View {
        Button(action: onToggleFavorite) {
            Image(systemName: isFavorite ? AppImages.favoriteFilled : AppImages.favorite)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isFavorite ? AppColors.rose : AppColors.textSecondary)
                .frame(width: 30, height: 30)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(isFavorite ? Text("Remove from Wishlist") : Text("Add to Wishlist"))
        .accessibilityIdentifier("product.favorite")
    }

    @ViewBuilder
    private var cornerBadge: some View {
        if !isInStock {
            badge(Text("Sold Out"), color: AppColors.textSecondary)
        } else if let discountPercent {
            badge(Text(verbatim: "-\(discountPercent)%"), color: AppColors.primary)
        }
    }

    private func badge(_ text: Text, color: Color) -> some View {
        text
            .font(AppFont.captionEmphasized)
            .foregroundStyle(AppColors.onPrimary)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(color, in: Capsule())
            .padding(AppSpacing.xs)
    }

    private var addButton: some View {
        Button(action: onAddToCart) {
            Image(systemName: AppImages.add)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppColors.onPrimary)
                .frame(width: 28, height: 28)
                .background(isInStock ? AppColors.primary : AppColors.textTertiary, in: Circle())
        }
        .buttonStyle(.borderless)
        .disabled(!isInStock)
        .accessibilityLabel(Text("Add to Cart"))
        .accessibilityIdentifier("product.addToCart")
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: AppSpacing.md) {
            ForEach(Product.mocks.prefix(4)) { product in
                ProductCardView(product: product, isFavorite: product == .mock, onToggleFavorite: {}, onAddToCart: {})
                    .frame(width: 160)
            }
            ProductCardView(product: .mockOutOfStock, isFavorite: false, onToggleFavorite: {}, onAddToCart: {})
                .frame(width: 160)
        }
        .padding()
    }
    .background(AppColors.background)
}

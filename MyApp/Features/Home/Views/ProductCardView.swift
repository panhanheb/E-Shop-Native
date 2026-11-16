import SwiftUI

/// Grid cell showing a product's image, name, rating, and price.
struct ProductCardView: View {
    /// The product to display.
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ProductImageView(product: product, iconSize: AppFontSize.iconLarge * 0.75)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
                .overlay(alignment: .topLeading) {
                    if product.stock == 0 {
                        cornerBadge("Out of Stock", color: AppColors.textSecondary)
                    } else if let originalPrice = product.originalPrice, originalPrice > product.price {
                        cornerBadge("Sale", color: AppColors.danger)
                    }
                }

            Text(product.name)
                .font(AppFont.callout)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)

            RatingView(rating: product.rating, reviewCount: product.reviewCount)

            PriceText(product.price, originalPrice: product.originalPrice)
        }
        .padding(AppSpacing.sm)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: AppRadius.large))
        .opacity(product.stock == 0 ? 0.6 : 1)
    }

    private func cornerBadge(_ title: LocalizedStringKey, color: Color) -> some View {
        Text(title)
            .font(AppFont.captionEmphasized)
            .foregroundStyle(AppColors.onPrimary)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(color, in: Capsule())
            .padding(AppSpacing.sm)
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
        ForEach(Product.mocks.prefix(4)) { ProductCardView(product: $0) }
    }
    .padding()
    .background(AppColors.background)
}

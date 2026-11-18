import SwiftUI

/// Product card: edge-to-edge image with a discount or free-delivery ribbon and wishlist heart,
/// then price, name, tagline (or low-stock hint), and a round animated add button.
struct ProductCardView: View {
    let product: Product
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onAddToCart: () -> Void

    /// Stock at or below this shows an "Only N left" hint.
    private static let lowStockThreshold = 10

    @State private var justAdded = false
    @State private var heartBounce = 0

    private var isInStock: Bool { product.stock > 0 }
    private var isLowStock: Bool { isInStock && product.stock <= Self.lowStockThreshold }

    private var discountPercent: Int? {
        guard let originalPrice = product.originalPrice, originalPrice > product.price, originalPrice > 0 else { return nil }
        let fraction = (originalPrice - product.price) / originalPrice * 100
        return Int(NSDecimalNumber(decimal: fraction).doubleValue.rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection
            infoSection
                .padding(AppSpacing.sm + AppSpacing.xxs)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .cardStyle()
        .contentShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    // MARK: Image

    private var imageSection: some View {
        ProductImageView(product: product, iconSize: AppFontSize.iconLarge * 0.7)
            .aspectRatio(1, contentMode: .fit)
            .saturation(isInStock ? 1 : 0)
            .overlay { if !isInStock { soldOutOverlay } }
            .overlay(alignment: .topTrailing) { favoriteButton }
            .overlay(alignment: .topLeading) { discountBadge }
    }

    private var soldOutOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
            Text("Sold Out")
                .font(AppFont.captionEmphasized)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(AppColors.onPrimary)
                .padding(.horizontal, AppSpacing.sm + AppSpacing.xxs)
                .padding(.vertical, AppSpacing.xs)
                .background(.black.opacity(0.6), in: Capsule())
        }
    }

    private var favoriteButton: some View {
        Button {
            heartBounce += 1
            onToggleFavorite()
        } label: {
            Image(systemName: isFavorite ? AppImages.favoriteFilled : AppImages.favorite)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isFavorite ? AppColors.primary : AppColors.textSecondary)
                .symbolEffect(.bounce, value: heartBounce)
                .frame(width: 32, height: 32)
                .background(AppColors.surface, in: Circle())
                .shadow(color: .black.opacity(0.08), radius: 4, y: 1)
                .padding(AppSpacing.sm)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .sensoryFeedback(.impact(weight: .light), trigger: heartBounce)
        .accessibilityLabel(isFavorite ? Text("Remove from Wishlist") : Text("Add to Wishlist"))
        .accessibilityIdentifier("product.favorite")
    }

    /// Discount badge for sale items; otherwise a "Free Delivery" ribbon when this item alone
    /// reaches the free-shipping threshold.
    @ViewBuilder
    private var discountBadge: some View {
        if isInStock, let discountPercent {
            ribbon(Text(verbatim: "-\(discountPercent)%"), systemImage: AppImages.offers, color: AppColors.primary)
        } else if isInStock, product.price >= ShippingPolicy.freeShippingThreshold {
            ribbon(Text("Free Delivery"), systemImage: "box.truck.fill", color: AppColors.info)
        }
    }

    private func ribbon(_ title: Text, systemImage: String, color: Color) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 9, weight: .bold))
            title
        }
        .font(AppFont.captionEmphasized)
        .foregroundStyle(AppColors.onPrimary)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(color, in: UnevenRoundedRectangle(bottomTrailingRadius: AppRadius.small, topTrailingRadius: AppRadius.small, style: .continuous))
        .padding(.top, AppSpacing.sm + AppSpacing.xxs)
    }

    // MARK: Info

    private var infoSection: some View {
        HStack(alignment: .center, spacing: AppSpacing.xs) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs + 1) {
                priceLine

                Text(product.name)
                    .font(AppFont.subheadline.weight(.medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                // Low stock replaces the tagline so every card keeps the same height.
                Group {
                    if isLowStock {
                        Text("Only \(product.stock) left")
                            .foregroundStyle(AppColors.warning)
                    } else {
                        Text(product.tagline)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .font(AppFont.caption)
                .lineLimit(1)
            }

            Spacer(minLength: 0)

            addButton
        }
    }

    private var priceLine: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xs) {
            Text(product.price, format: .currency(code: AppCurrency.code))
                .font(AppFont.price)
                .foregroundStyle(discountPercent != nil ? AppColors.primary : AppColors.textPrimary)
            if discountPercent != nil, let originalPrice = product.originalPrice {
                Text(originalPrice, format: .currency(code: AppCurrency.code))
                    .font(.caption2)
                    .strikethrough()
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }

    private var addButton: some View {
        Button {
            onAddToCart()
            withAnimation(.spring(duration: 0.3)) { justAdded = true }
            Task {
                try? await Task.sleep(for: .seconds(1.2))
                withAnimation(.spring(duration: 0.3)) { justAdded = false }
            }
        } label: {
            Image(systemName: justAdded ? "checkmark" : AppImages.add)
                .font(.system(size: 16, weight: .bold))
                .contentTransition(.symbolEffect(.replace))
                .foregroundStyle(AppColors.onPrimary)
                .frame(width: 38, height: 38)
                .background(
                    isInStock ? (justAdded ? AppColors.success : AppColors.primary) : AppColors.textTertiary,
                    in: Circle()
                )
        }
        .buttonStyle(.borderless)
        .disabled(!isInStock || justAdded)
        .sensoryFeedback(.success, trigger: justAdded) { _, new in new }
        .accessibilityLabel(Text("Add to Cart"))
        .accessibilityIdentifier("product.addToCart")
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: AppSpacing.md)], spacing: AppSpacing.md) {
            ForEach(Product.mocks.prefix(5)) { product in
                ProductCardView(product: product, isFavorite: product == .mock, onToggleFavorite: {}, onAddToCart: {})
            }
            ProductCardView(product: .mockOutOfStock, isFavorite: false, onToggleFavorite: {}, onAddToCart: {})
        }
        .padding()
    }
    .background(AppColors.background)
}

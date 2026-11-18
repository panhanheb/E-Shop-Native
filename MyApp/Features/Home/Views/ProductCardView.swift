import SwiftUI

/// Product card: edge-to-edge image with discount badge and wishlist heart, then name, rating,
/// price (sale price with the original struck through), stock hint, and an animated add button.
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

    @ViewBuilder
    private var discountBadge: some View {
        if isInStock, let discountPercent {
            Text(verbatim: "-\(discountPercent)%")
                .font(AppFont.captionEmphasized)
                .foregroundStyle(AppColors.onPrimary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xxs + 1)
                .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .padding(AppSpacing.sm + AppSpacing.xxs)
        }
    }

    // MARK: Info

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs + AppSpacing.xxs) {
            Text(product.name)
                .font(AppFont.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)

            compactRating

            HStack(alignment: .bottom, spacing: AppSpacing.xs) {
                priceStack
                Spacer(minLength: 0)
                addButton
            }

            stockHint
        }
    }

    private var compactRating: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: AppImages.star)
                .font(.system(size: 10))
                .foregroundStyle(AppColors.star)
            Text(product.rating, format: .number.precision(.fractionLength(1)))
                .font(AppFont.captionEmphasized)
                .foregroundStyle(AppColors.textPrimary)
            Text("(\(product.reviewCount))")
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textSecondary)
            Text(verbatim: "·")
                .foregroundStyle(AppColors.textTertiary)
            Text(product.category.title)
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Rated \(product.rating, specifier: "%.1f") out of 5, \(product.reviewCount) reviews"))
    }

    private var priceStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            if discountPercent != nil, let originalPrice = product.originalPrice {
                Text(originalPrice, format: .currency(code: AppCurrency.code))
                    .font(.caption2)
                    .strikethrough()
                    .foregroundStyle(AppColors.textSecondary)
            }
            Text(product.price, format: .currency(code: AppCurrency.code))
                .font(AppFont.price)
                .foregroundStyle(discountPercent != nil ? AppColors.primary : AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    /// Always laid out (hidden when not low) so every card in a row has the same height.
    private var stockHint: some View {
        Text("Only \(product.stock) left")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(AppColors.warning)
            .opacity(isLowStock ? 1 : 0)
            .accessibilityHidden(!isLowStock)
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
                .font(.system(size: 15, weight: .bold))
                .contentTransition(.symbolEffect(.replace))
                .foregroundStyle(AppColors.onPrimary)
                .frame(width: 34, height: 34)
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

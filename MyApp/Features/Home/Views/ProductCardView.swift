import SwiftUI

/// Product card: image with badges and wishlist heart, category, name, rating,
/// sale price with the original struck through, stock hint, and an animated add button.
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
                .padding(.horizontal, AppSpacing.sm + AppSpacing.xxs)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.sm + AppSpacing.xxs)
        }
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .strokeBorder(AppColors.border.opacity(0.35), lineWidth: 0.5)
        }
        .shadow(color: AppColors.shadow, radius: 10, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    // MARK: Image

    private var imageSection: some View {
        ProductImageView(product: product, iconSize: AppFontSize.iconLarge * 0.7)
            .aspectRatio(1, contentMode: .fit)
            .saturation(isInStock ? 1 : 0)
            .overlay { if !isInStock { soldOutOverlay } }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
            .overlay(alignment: .topTrailing) { favoriteButton }
            .overlay(alignment: .topLeading) { discountBadge }
            .padding(AppSpacing.xs + AppSpacing.xxs)
    }

    private var soldOutOverlay: some View {
        ZStack {
            Color.black.opacity(0.25)
            Text("Sold Out")
                .font(AppFont.captionEmphasized)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(AppColors.onPrimary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(.black.opacity(0.55), in: Capsule())
        }
    }

    private var favoriteButton: some View {
        Button {
            heartBounce += 1
            onToggleFavorite()
        } label: {
            Image(systemName: isFavorite ? AppImages.favoriteFilled : AppImages.favorite)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isFavorite ? AppColors.rose : AppColors.textPrimary)
                .symbolEffect(.bounce, value: heartBounce)
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial, in: Circle())
                .padding(AppSpacing.sm)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
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
                .background(AppColors.berry.gradient, in: Capsule())
                .padding(AppSpacing.sm)
        }
    }

    // MARK: Info

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(product.category.title)
                .font(.caption2.weight(.semibold))
                .textCase(.uppercase)
                .tracking(0.6)
                .foregroundStyle(product.category.tint)
                .lineLimit(1)

            Text(product.name)
                .font(AppFont.callout.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)

            compactRating

            HStack(alignment: .bottom, spacing: AppSpacing.xs) {
                priceStack
                Spacer(minLength: 0)
                addButton
            }
            .padding(.top, AppSpacing.xxs)

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
                .font(AppFont.headline)
                .foregroundStyle(discountPercent != nil ? AppColors.berry : AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    /// Always laid out (hidden when not low) so every card in a row has the same height.
    private var stockHint: some View {
        Label {
            Text("Only \(product.stock) left")
        } icon: {
            Image(systemName: "flame.fill")
        }
        .font(.caption2.weight(.medium))
        .foregroundStyle(AppColors.warning)
        .labelStyle(.titleAndIcon)
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
            Image(systemName: justAdded ? "checkmark" : AppImages.addToCart)
                .font(.system(size: 14, weight: .semibold))
                .contentTransition(.symbolEffect(.replace))
                .foregroundStyle(AppColors.onPrimary)
                .frame(width: 36, height: 36)
                .background(
                    isInStock ? (justAdded ? AppColors.success : AppColors.primary) : AppColors.textTertiary,
                    in: RoundedRectangle(cornerRadius: AppRadius.small + 2, style: .continuous)
                )
                .shadow(color: isInStock ? AppColors.primary.opacity(0.3) : .clear, radius: 6, y: 3)
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

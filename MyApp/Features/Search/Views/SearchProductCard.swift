import SwiftUI

/// Softly tinted product card for search results: name and heart on top, image in the middle,
/// and a price pill with an add-to-bag button at the bottom.
struct SearchProductCard: View {
    let product: Product
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onAddToCart: () -> Void

    @State private var justAdded = false

    private var isInStock: Bool { product.stock > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .top, spacing: AppSpacing.xs) {
                Text(product.name)
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                favoriteButton
            }

            ProductImageView(product: product, iconSize: 52, showsBackground: false)
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .saturation(isInStock ? 1 : 0)

            pricePill
        }
        .padding(AppSpacing.sm + AppSpacing.xxs)
        .background {
            let shape = RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
            ZStack {
                shape.fill(AppColors.surface)
                shape.fill(product.category.tint.opacity(0.12))
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private var favoriteButton: some View {
        Button(action: onToggleFavorite) {
            Image(systemName: isFavorite ? AppImages.favoriteFilled : AppImages.favorite)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isFavorite ? AppColors.primary : AppColors.textSecondary)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 30, height: 30)
                .background(AppColors.surface.opacity(0.8), in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.borderless)
        .sensoryFeedback(.impact(weight: .light), trigger: isFavorite)
        .accessibilityLabel(isFavorite ? Text("Remove from Wishlist") : Text("Add to Wishlist"))
    }

    private var pricePill: some View {
        HStack(spacing: AppSpacing.xs) {
            VStack(alignment: .leading, spacing: 0) {
                Text(product.price, format: .currency(code: AppCurrency.code))
                    .font(AppFont.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(AppColors.textPrimary)
                if !isInStock {
                    Text("Sold Out")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColors.danger)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            Button {
                onAddToCart()
                withAnimation(.spring(duration: 0.3)) { justAdded = true }
                Task {
                    try? await Task.sleep(for: .seconds(1.2))
                    withAnimation(.spring(duration: 0.3)) { justAdded = false }
                }
            } label: {
                Image(systemName: justAdded ? "checkmark" : AppImages.cart)
                    .font(.system(size: 13, weight: .bold))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(justAdded ? AppColors.onPrimary : AppColors.primary)
                    .frame(width: 32, height: 32)
                    .background(justAdded ? AppColors.success : AppColors.primarySoft, in: Circle())
            }
            .buttonStyle(.borderless)
            .disabled(!isInStock || justAdded)
            .opacity(isInStock ? 1 : 0.4)
            .sensoryFeedback(.success, trigger: justAdded) { _, new in new }
            .accessibilityLabel(Text("Add to Cart"))
        }
        .padding(.leading, AppSpacing.sm + AppSpacing.xxs)
        .padding(.trailing, AppSpacing.xs)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColors.surface.opacity(0.75), in: Capsule())
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible())], spacing: AppSpacing.md) {
        ForEach(Product.mocks.prefix(3)) { product in
            SearchProductCard(product: product, isFavorite: product == .mock, onToggleFavorite: {}, onAddToCart: {})
        }
        SearchProductCard(product: .mockOutOfStock, isFavorite: false, onToggleFavorite: {}, onAddToCart: {})
    }
    .padding()
    .background(AppColors.background)
}

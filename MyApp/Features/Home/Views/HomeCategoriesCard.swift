import SwiftUI

/// White card with one round icon per category and a "View More Categories" button underneath.
struct HomeCategoriesCard: View {
    /// Opens the Categories tab.
    let onViewMore: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(ProductCategory.allCases) { category in
                    NavigationLink(value: ProductCollection.category(category)) {
                        VStack(spacing: AppSpacing.sm) {
                            Image(systemName: category.systemImage)
                                .font(.system(size: 22))
                                .foregroundStyle(category.tint.gradient)
                                .frame(width: 54, height: 54)
                                .background(category.tint.opacity(0.12), in: Circle())
                            Text(category.title)
                                .font(AppFont.caption.weight(.medium))
                                .foregroundStyle(AppColors.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.pressable)
                }
            }

            Button(action: onViewMore) {
                Label("View More Categories", systemImage: AppImages.categories)
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(AppColors.primarySoft, in: Capsule())
            }
            .buttonStyle(.pressable)
        }
        .padding(AppSpacing.md)
        .cardStyle()
    }
}

/// A product shown as a circular thumbnail with its name underneath, for horizontal rows.
struct ProductCircleView: View {
    let product: Product

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ProductImageView(product: product, iconSize: 24)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(AppColors.hairline, lineWidth: 1))
                .shadow(color: AppColors.shadow, radius: 4, y: 2)
            Text(product.name)
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
        }
        .frame(width: 72)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        VStack(spacing: AppSpacing.lg) {
            HomeCategoriesCard {}
            HStack {
                ForEach(Product.mocks.prefix(4)) { ProductCircleView(product: $0) }
            }
        }
        .padding()
        .background(AppColors.background)
    }
}

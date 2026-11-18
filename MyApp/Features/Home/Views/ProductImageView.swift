import SwiftUI

/// Product photo loaded from `imageURL`, with a styled category icon as placeholder.
struct ProductImageView: View {
    /// The product whose image to show.
    let product: Product
    /// Size of the placeholder icon.
    var iconSize: CGFloat = AppFontSize.iconLarge

    var body: some View {
        ZStack {
            AppColors.surface
            product.category.tint.opacity(0.08)

            if let imageURL = product.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit().padding(AppSpacing.sm)
                    case .failure:
                        placeholder
                    default:
                        ProgressView()
                    }
                }
            } else {
                placeholder
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        Image(systemName: product.category.systemImage)
            .font(AppFont.icon(iconSize))
            .foregroundStyle(product.category.tint.gradient)
    }
}

#Preview {
    HStack {
        ForEach(ProductCategory.allCases) { category in
            ProductImageView(product: Product.mocks.first { $0.category == category } ?? .mock, iconSize: 28)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
        }
    }
    .padding()
}

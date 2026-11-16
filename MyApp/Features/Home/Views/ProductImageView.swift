import SwiftUI

/// Product photo loaded from `imageURL`, with a category icon as placeholder.
struct ProductImageView: View {
    /// The product whose image to show.
    let product: Product
    /// Size of the placeholder icon.
    var iconSize: CGFloat = AppFontSize.iconLarge

    var body: some View {
        ZStack {
            Rectangle()
                .fill(product.category.tint.opacity(0.12))

            if let imageURL = product.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
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
            .foregroundStyle(product.category.tint)
    }
}

#Preview {
    ProductImageView(product: .mock)
        .frame(width: 160, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
}

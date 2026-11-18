import SwiftUI

/// Two-column grid of product cards.
struct ProductGridView: View {
    let products: [Product]
    /// Called after a product is added to the cart.
    var onAdded: (Product) -> Void = { _ in }

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.md) {
            ForEach(products) { product in
                ProductCardLink(product: product, onAdded: onAdded)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ProductGridView(products: Product.mocks)
                .padding()
        }
        .background(AppColors.background)
    }
    .environment(DependencyContainer.preview)
}

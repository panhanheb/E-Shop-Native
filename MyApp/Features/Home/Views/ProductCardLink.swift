import SwiftUI

/// A `ProductCardView` that opens the product's detail screen and is wired to the shared cart and wishlist.
struct ProductCardLink: View {
    let product: Product
    /// Called after the product is added to the cart (e.g. to show a toast).
    var onAdded: (Product) -> Void = { _ in }

    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        NavigationLink(value: product) {
            ProductCardView(
                product: product,
                isFavorite: dependencies.wishlistViewModel.contains(product),
                onToggleFavorite: { dependencies.wishlistViewModel.toggle(product) },
                onAddToCart: {
                    dependencies.cartViewModel.add(product)
                    onAdded(product)
                }
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("product.card")
    }
}

#Preview {
    NavigationStack {
        ProductCardLink(product: .mock)
            .frame(width: 170)
            .padding()
    }
    .environment(AppDependencies.preview)
}

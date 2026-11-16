import SwiftUI

/// Wishlist tab: products the customer has hearted, in a grid.
struct WishlistView: View {
    /// Shared wishlist.
    let wishlist: WishlistViewModel
    /// Takes the customer back to Home from the empty state.
    let onStartShopping: () -> Void

    @Environment(AppDependencies.self) private var dependencies
    @State private var toastMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if wishlist.isEmpty {
                    EmptyStateView(
                        title: "Your Wishlist Is Empty",
                        systemImage: AppImages.wishlist,
                        message: "Tap the heart on any product to save it here.",
                        actionTitle: "Start Shopping"
                    ) {
                        onStartShopping()
                    }
                } else {
                    ScrollView {
                        ProductGridView(products: wishlist.products) { product in
                            toastMessage = String(localized: "\(product.name) added to your bag")
                        }
                        .padding(AppSpacing.md)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .navigationTitle("Wishlist")
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(viewModel: dependencies.makeProductDetailViewModel(product: product))
            }
            .toast(message: $toastMessage)
        }
    }
}

#Preview("Saved Items") {
    let dependencies = AppDependencies.preview
    WishlistView(wishlist: dependencies.wishlistViewModel, onStartShopping: {})
        .environment(dependencies)
}

#Preview("Empty") {
    WishlistView(wishlist: WishlistViewModel(), onStartShopping: {})
        .environment(AppDependencies.preview)
}

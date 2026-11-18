import SwiftUI

/// Full-screen grid for a collection: a category, best sellers, offers, or all products.
struct ProductCollectionView: View {
    /// Shared catalog.
    @Bindable var catalog: ProductListViewModel
    let collection: ProductCollection

    @State private var toastMessage: String?

    var body: some View {
        let products = catalog.products(in: collection)

        Group {
            if !catalog.hasLoaded, let errorMessage = catalog.errorMessage {
                ErrorStateView(message: errorMessage) {
                    Task { await catalog.loadProducts() }
                }
            } else if !catalog.hasLoaded {
                LoadingView(message: "Loading products…")
            } else if products.isEmpty {
                EmptyStateView(
                    title: "Nothing Here Yet",
                    systemImage: AppImages.categories,
                    message: "New products are on the way. Check back soon."
                )
            } else {
                ScrollView {
                    ProductGridView(products: products) { product in
                        toastMessage = String(localized: "\(product.name) added to your bag")
                    }
                    .padding(AppSpacing.md)
                }
                .refreshable { await catalog.loadProducts() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .navigationTitle(collection.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Sort By", selection: $catalog.sort) {
                        ForEach(ProductSort.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Label("Sort By", systemImage: AppImages.sort)
                }
            }
        }
        .toast(message: $toastMessage)
        .task { await catalog.loadIfNeeded() }
    }
}

#Preview {
    let dependencies = DependencyContainer.preview
    NavigationStack {
        ProductCollectionView(catalog: dependencies.catalogViewModel, collection: .category(.skincare))
    }
    .environment(dependencies)
}

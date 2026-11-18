import SwiftUI

/// Categories tab: one card per category (plus Offers) that opens its product grid.
struct CategoriesView: View {
    /// Shared catalog.
    @Bindable var catalog: ProductListViewModel
    @Environment(DependencyContainer.self) private var dependencies

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
                .navigationTitle("Categories")
                .navigationDestination(for: ProductCollection.self) { collection in
                    ProductCollectionView(catalog: catalog, collection: collection)
                }
                .navigationDestination(for: Product.self) { product in
                    ProductDetailView(viewModel: dependencies.makeProductDetailViewModel(product: product))
                }
                .task { await catalog.loadIfNeeded() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if !catalog.hasLoaded, let errorMessage = catalog.errorMessage {
            ErrorStateView(message: errorMessage) {
                Task { await catalog.loadProducts() }
            }
        } else if !catalog.hasLoaded {
            LoadingView(message: "Loading products…")
        } else {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    ForEach(ProductCategory.allCases) { category in
                        NavigationLink(value: ProductCollection.category(category)) {
                            row(
                                title: category.title,
                                systemImage: category.systemImage,
                                tint: category.tint,
                                count: catalog.productCount(in: category)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    NavigationLink(value: ProductCollection.offers) {
                        row(
                            title: "Offers",
                            systemImage: AppImages.offers,
                            tint: AppColors.primary,
                            count: catalog.offers.count
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(AppSpacing.md)
            }
            .refreshable { await catalog.loadProducts() }
        }
    }

    private func row(title: LocalizedStringKey, systemImage: String, tint: Color, count: Int) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(tint.gradient)
                .frame(width: 56, height: 56)
                .background(AppColors.blush, in: Circle())

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(count) products")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: AppImages.arrowRight)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: AppRadius.large))
        .shadow(color: AppColors.shadow, radius: 6, y: 2)
    }
}

#Preview {
    let dependencies = DependencyContainer.preview
    CategoriesView(catalog: dependencies.catalogViewModel)
        .environment(dependencies)
}

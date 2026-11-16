import SwiftUI

/// The Home screen: greeting header, hero banners, search, category circles,
/// Best Sellers row, special-offer banner, and a "Just For You" grid.
struct HomeView: View {
    /// Shared catalog.
    @Bindable var catalog: ProductListViewModel

    @Environment(AppDependencies.self) private var dependencies
    @State private var path = NavigationPath()
    @State private var isShowingCart = false
    @State private var isShowingSettings = false
    @State private var isShowingNotifications = false
    @State private var toastMessage: String?

    private var firstName: String {
        dependencies.sessionStore.currentUser?.name
            .split(separator: " ")
            .first
            .map(String.init) ?? String(localized: "Beautiful")
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    HomeHeaderView(
                        firstName: firstName,
                        cartCount: dependencies.cartViewModel.itemCount,
                        onOpenSettings: { isShowingSettings = true },
                        onOpenNotifications: { isShowingNotifications = true },
                        onOpenCart: { isShowingCart = true }
                    )
                    .padding(.horizontal, AppSpacing.md)

                    if !catalog.isSearching {
                        HeroBannerCarousel { collection in
                            path.append(collection)
                        }
                    }

                    HomeSearchBar(text: $catalog.searchText, sort: $catalog.sort)
                        .padding(.horizontal, AppSpacing.md)

                    if catalog.isSearching {
                        searchResults
                    } else {
                        categoryCircles
                        catalogSections
                    }
                }
                .padding(.vertical, AppSpacing.sm)
            }
            .scrollDismissesKeyboard(.immediately)
            .background(AppColors.background)
            .refreshable { await catalog.loadProducts() }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(viewModel: dependencies.makeProductDetailViewModel(product: product))
            }
            .navigationDestination(for: ProductCollection.self) { collection in
                ProductCollectionView(catalog: catalog, collection: collection)
            }
            .sheet(isPresented: $isShowingCart) {
                CartView(cart: dependencies.cartViewModel, onClose: { isShowingCart = false }) {
                    isShowingCart = false
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(viewModel: dependencies.settingsViewModel)
            }
            .sheet(isPresented: $isShowingNotifications) {
                NotificationsView()
            }
            .alert("Something Went Wrong", isPresented: $catalog.isErrorAlertPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(catalog.errorMessage ?? "")
            }
            .toast(message: $toastMessage)
            .task { await catalog.loadIfNeeded() }
        }
    }

    // MARK: Sections

    private var categoryCircles: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                ForEach(ProductCategory.allCases) { category in
                    NavigationLink(value: ProductCollection.category(category)) {
                        CategoryCircleView(
                            title: category.title,
                            systemImage: category.systemImage,
                            tint: category.tint,
                            isHighlighted: category == .skincare
                        )
                    }
                    .buttonStyle(.plain)
                }

                NavigationLink(value: ProductCollection.offers) {
                    CategoryCircleView(title: "Offers", systemImage: AppImages.offers, tint: AppColors.primary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
        }
    }

    @ViewBuilder
    private var catalogSections: some View {
        if !catalog.hasLoaded, let errorMessage = catalog.errorMessage {
            ErrorStateView(message: errorMessage) {
                Task { await catalog.loadProducts() }
            }
            .frame(minHeight: 280)
        } else if !catalog.hasLoaded {
            LoadingView(message: "Loading products…")
                .frame(height: 240)
        } else if catalog.products.isEmpty {
            EmptyStateView(
                title: "No Products Yet",
                systemImage: AppImages.cart,
                message: "New products are on the way. Pull to refresh or check back soon.",
                actionTitle: "Refresh"
            ) {
                Task { await catalog.loadProducts() }
            }
            .frame(minHeight: 280)
        } else {
            bestSellers

            if let discount = catalog.maxDiscountPercent {
                SpecialOfferBanner(discountPercent: discount) {
                    path.append(ProductCollection.offers)
                }
                .padding(.horizontal, AppSpacing.md)
            }

            VStack(spacing: AppSpacing.md) {
                SectionHeaderView(title: "Just For You", destination: ProductCollection.all)
                ProductGridView(products: catalog.products(in: .all), onAdded: { showAddedToast($0) })
            }
            .padding(.horizontal, AppSpacing.md)
        }
    }

    private var bestSellers: some View {
        VStack(spacing: AppSpacing.md) {
            SectionHeaderView(title: "Best Sellers", destination: ProductCollection.bestSellers)
                .padding(.horizontal, AppSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(catalog.bestSellers) { product in
                        ProductCardLink(product: product, onAdded: { showAddedToast($0) })
                            .frame(width: 156)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        if catalog.searchResults.isEmpty {
            EmptyStateView(
                title: "No Matching Products",
                systemImage: AppImages.search,
                message: "Try a different search or category."
            )
            .frame(minHeight: 280)
        } else {
            ProductGridView(products: catalog.searchResults, onAdded: { showAddedToast($0) })
                .padding(.horizontal, AppSpacing.md)
        }
    }

    private func showAddedToast(_ product: Product) {
        toastMessage = String(localized: "\(product.name) added to your bag")
    }
}

#Preview("Home") {
    let dependencies = AppDependencies.preview
    HomeView(catalog: dependencies.catalogViewModel)
        .environment(dependencies)
}

#Preview("Empty Catalog") {
    let dependencies = AppDependencies.preview
    HomeView(catalog: ProductListViewModel(productService: MockProductService(products: [], latency: .zero)))
        .environment(dependencies)
}

#Preview("Khmer") {
    let dependencies = AppDependencies.preview
    HomeView(catalog: dependencies.catalogViewModel)
        .environment(dependencies)
        .environment(\.locale, Locale(identifier: "km"))
}

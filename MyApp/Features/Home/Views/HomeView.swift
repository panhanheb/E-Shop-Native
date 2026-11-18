import SwiftUI

/// The Home screen: profile header, search, promo banners, categories, Top Picks,
/// Best Sellers, and a "Just For You" grid. While searching, shows filter chips and a results grid.
struct HomeView: View {
    /// Shared catalog.
    @Bindable var catalog: ProductListViewModel
    /// Switches the main tab bar (Categories, Profile).
    var onSelectTab: (AppTab) -> Void = { _ in }

    /// Shown under the name. Replace with the customer's saved address once addresses are stored.
    private static let defaultLocation = String(localized: "Phnom Penh, Cambodia")
    private static let topPicksLimit = 10

    @Environment(DependencyContainer.self) private var dependencies
    @State private var path = NavigationPath()
    @State private var isShowingCart = false
    @State private var isShowingNotifications = false
    @State private var toastMessage: String?
    /// Search filters.
    @State private var searchCategory: ProductCategory?
    @State private var isOnSaleOnly = false

    private var userName: String {
        let name = dependencies.sessionStore.currentUser?.name ?? ""
        return name.isEmpty ? String(localized: "Welcome") : name
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    VStack(spacing: AppSpacing.md) {
                        HomeHeaderView(
                            userName: userName,
                            locationName: Self.defaultLocation,
                            cartCount: dependencies.cartViewModel.itemCount,
                            onOpenProfile: { onSelectTab(.profile) },
                            onOpenCart: { isShowingCart = true },
                            onOpenNotifications: { isShowingNotifications = true }
                        )
                        HomeSearchBar(text: $catalog.searchText, sort: $catalog.sort)
                    }
                    .padding(.horizontal, AppSpacing.md)

                    if catalog.isSearching {
                        searchResults
                    } else {
                        HeroBannerCarousel { collection in
                            path.append(collection)
                        }

                        HomeCategoriesCard { onSelectTab(.categories) }
                            .padding(.horizontal, AppSpacing.md)

                        catalogSections
                    }
                }
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.lg)
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

    // MARK: Catalog sections

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
            topPicks
            bestSellers
            justForYou
        }
    }

    private var topPicks: some View {
        section(title: "Top Picks", destination: .all) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: AppSpacing.sm + AppSpacing.xxs) {
                    ForEach(catalog.products.prefix(Self.topPicksLimit)) { product in
                        NavigationLink(value: product) {
                            ProductCircleView(product: product)
                        }
                        .buttonStyle(.pressable)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }

    private var bestSellers: some View {
        section(title: "Best Sellers", destination: .bestSellers) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm + AppSpacing.xs) {
                    ForEach(catalog.bestSellers) { product in
                        ProductCardLink(product: product, onAdded: { showAddedToast($0) })
                            .frame(width: 168)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }

    private var justForYou: some View {
        section(title: "Just For You", destination: .all) {
            ProductGridView(products: catalog.products(in: .all), onAdded: { showAddedToast($0) })
                .padding(.horizontal, AppSpacing.md)
        }
    }

    // MARK: Search

    private var filteredSearchResults: [Product] {
        catalog.searchResults.filter { product in
            let matchesCategory = searchCategory.map { product.category == $0 } ?? true
            let matchesSale = !isOnSaleOnly || (product.originalPrice.map { $0 > product.price } ?? false)
            return matchesCategory && matchesSale
        }
    }

    private var searchResults: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            searchFilters

            let results = filteredSearchResults
            if results.isEmpty {
                EmptyStateView(
                    title: "No Matching Products",
                    systemImage: AppImages.search,
                    message: "Try a different search or category."
                )
                .frame(minHeight: 280)
            } else {
                Text("\(results.count) results")
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, AppSpacing.md)

                ProductGridView(products: results, onAdded: { showAddedToast($0) })
                    .padding(.horizontal, AppSpacing.md)
            }
        }
    }

    private var searchFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                Menu {
                    Picker("Sort By", selection: $catalog.sort) {
                        ForEach(ProductSort.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    FilterChip(title: "Sort By", systemImage: AppImages.sort, isSelected: catalog.sort != .featured)
                }

                Button {
                    isOnSaleOnly.toggle()
                } label: {
                    FilterChip(title: "On Sale", systemImage: AppImages.offers, isSelected: isOnSaleOnly)
                }
                .buttonStyle(.plain)

                ForEach(ProductCategory.allCases) { category in
                    Button {
                        searchCategory = searchCategory == category ? nil : category
                    } label: {
                        FilterChip(title: category.title, isSelected: searchCategory == category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .sensoryFeedback(.selection, trigger: searchCategory)
        .sensoryFeedback(.selection, trigger: isOnSaleOnly)
    }

    // MARK: Helpers

    /// A titled Home section whose content can scroll edge to edge.
    private func section<Content: View>(
        title: LocalizedStringKey,
        destination: ProductCollection? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            SectionHeaderView(title: title, destination: destination)
                .padding(.horizontal, AppSpacing.md)
            content()
        }
    }

    private func showAddedToast(_ product: Product) {
        toastMessage = String(localized: "\(product.name) added to your bag")
    }
}

#Preview("Home") {
    let dependencies = DependencyContainer.preview
    HomeView(catalog: dependencies.catalogViewModel)
        .environment(dependencies)
}

#Preview("Empty Catalog") {
    let dependencies = DependencyContainer.preview
    HomeView(catalog: ProductListViewModel(productService: MockProductService(products: [], latency: .zero)))
        .environment(dependencies)
}

#Preview("Khmer") {
    let dependencies = DependencyContainer.preview
    HomeView(catalog: dependencies.catalogViewModel)
        .environment(dependencies)
        .environment(\.locale, Locale(identifier: "km"))
}

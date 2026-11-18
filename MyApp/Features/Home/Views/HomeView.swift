import SwiftUI

/// The Home screen: red location/search header with quick actions, shortcut grid, promo banners,
/// Top Picks, Featured categories, Special Offers, discount codes, Trending, and What's New.
struct HomeView: View {
    /// Shared catalog.
    @Bindable var catalog: ProductListViewModel
    /// Switches the main tab bar (Favorites → Wishlist, Orders, Profile).
    var onSelectTab: (AppTab) -> Void = { _ in }

    /// Shown under "Your location". Replace with the customer's saved address once addresses are stored.
    private static let defaultLocation = String(localized: "Phnom Penh")
    private static let couponsAnchor = "home.coupons"
    private static let topPicksLimit = 12

    @Environment(DependencyContainer.self) private var dependencies
    @State private var path = NavigationPath()
    @State private var isShowingCart = false
    @State private var isShowingSettings = false
    @State private var isShowingNotifications = false
    @State private var toastMessage: String?

    var body: some View {
        NavigationStack(path: $path) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        header(proxy: proxy)

                        if catalog.isSearching {
                            searchResults
                        } else {
                            HomeShortcutGrid()
                                .padding(.horizontal, AppSpacing.md)

                            HeroBannerCarousel { collection in
                                path.append(collection)
                            }

                            catalogSections
                        }
                    }
                    .padding(.bottom, AppSpacing.lg)
                }
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

    // MARK: Header

    private func header(proxy: ScrollViewProxy) -> some View {
        HomeTopHeader(
            locationName: Self.defaultLocation,
            userName: dependencies.sessionStore.currentUser?.name ?? "",
            cartCount: dependencies.cartViewModel.itemCount,
            searchText: $catalog.searchText,
            sort: $catalog.sort,
            onOpenFavorites: { onSelectTab(.wishlist) },
            onOpenCart: { isShowingCart = true },
            onOpenOrders: { onSelectTab(.orders) },
            onOpenCoupons: {
                catalog.searchText = ""
                withAnimation { proxy.scrollTo(Self.couponsAnchor, anchor: .top) }
            },
            onOpenNotifications: { isShowingNotifications = true },
            onOpenSettings: { isShowingSettings = true },
            onOpenProfile: { onSelectTab(.profile) }
        )
    }

    // MARK: Sections

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
            featured
            if !catalog.offers.isEmpty {
                specialOffers
            }
            discountCodes
                .id(Self.couponsAnchor)
            trending
            whatsNew
        }
    }

    private var topPicks: some View {
        section(title: "Top Picks", destination: ProductCollection.all) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: twoRows(height: 76), spacing: AppSpacing.sm + AppSpacing.xs) {
                    ForEach(catalog.products.prefix(Self.topPicksLimit)) { product in
                        NavigationLink(value: product) {
                            TopPickTile(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }

    private var featured: some View {
        section(title: "Featured") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm + AppSpacing.xs) {
                    ForEach(ProductCategory.allCases) { category in
                        NavigationLink(value: ProductCollection.category(category)) {
                            FeaturedCategoryCard(category: category)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }

    private var specialOffers: some View {
        section(title: "Special Offers", destination: ProductCollection.offers) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: twoRows(height: 116), spacing: AppSpacing.sm + AppSpacing.xs) {
                    ForEach(catalog.offers) { product in
                        NavigationLink(value: product) {
                            SpecialOfferTile(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }

    private var discountCodes: some View {
        section(title: "Discover Discount Codes", destination: ProductCollection.offers) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm + AppSpacing.xs) {
                    ForEach(DiscountCode.featured) { discountCode in
                        Button {
                            UIPasteboard.general.string = discountCode.code
                            toastMessage = String(localized: "Code \(discountCode.code) copied")
                        } label: {
                            DiscountCodeCard(discountCode: discountCode)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }

    private var trending: some View {
        section(title: "Trending", destination: ProductCollection.bestSellers) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(catalog.bestSellers) { product in
                        ProductCardLink(product: product, onAdded: { showAddedToast($0) })
                            .frame(width: 170)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }

    private var whatsNew: some View {
        section(title: "What's New?") {
            WhatsNewBanner {
                path.append(ProductCollection.all)
            }
            .padding(.horizontal, AppSpacing.md)
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

    // MARK: Helpers

    /// A titled Home section whose content scrolls edge to edge.
    private func section<Content: View>(
        title: LocalizedStringKey,
        destination: ProductCollection? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HomeSectionTitle(title: title, destination: destination)
                .padding(.horizontal, AppSpacing.md)
            content()
        }
    }

    private func twoRows(height: CGFloat) -> [GridItem] {
        Array(repeating: GridItem(.fixed(height), spacing: AppSpacing.sm + AppSpacing.xs), count: 2)
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

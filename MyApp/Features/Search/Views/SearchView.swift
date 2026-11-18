import SwiftUI

/// Search screen: search field with sort button, recent searches while typing, category and
/// on-sale filter chips, and a grid of results ("Popular" before anything is typed).
///
/// Pushed onto the Home navigation stack, which provides the `Product` destination.
struct SearchView: View {
    /// Shared catalog: provides the query text, sort order, and text matching.
    @Bindable var catalog: ProductListViewModel
    /// Opens the cart from the toolbar bag button.
    let onOpenCart: () -> Void

    @State private var viewModel: SearchViewModel
    @Environment(DependencyContainer.self) private var dependencies
    @FocusState private var isFieldFocused: Bool
    @State private var toastMessage: String?

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.sm + AppSpacing.xs),
        GridItem(.flexible(), spacing: AppSpacing.sm + AppSpacing.xs)
    ]

    /// Creates the screen.
    init(catalog: ProductListViewModel, viewModel: SearchViewModel, onOpenCart: @escaping () -> Void) {
        self.catalog = catalog
        self.onOpenCart = onOpenCart
        _viewModel = State(initialValue: viewModel)
    }

    private var matchingRecentSearches: [String] {
        viewModel.recentSearches(matching: catalog.searchText)
    }

    /// Recent searches replace the results while the field is focused and some match.
    private var isShowingRecentSearches: Bool {
        isFieldFocused && !matchingRecentSearches.isEmpty
    }

    /// Before typing: most-reviewed products (or the chosen sort order). After: text matches.
    private var results: [Product] {
        let base: [Product] = if catalog.isSearching {
            catalog.searchResults
        } else if catalog.sort == .featured {
            catalog.products.sorted { $0.reviewCount > $1.reviewCount }
        } else {
            catalog.products(in: .all)
        }
        return viewModel.filter(base)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md + AppSpacing.xs) {
                searchRow
                    .padding(.horizontal, AppSpacing.md)

                if isShowingRecentSearches {
                    recentSearchesSection
                        .padding(.horizontal, AppSpacing.md)
                } else {
                    filterChips
                    resultsSection
                }
            }
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.lg)
            .animation(.easeInOut(duration: 0.2), value: isShowingRecentSearches)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.background)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onOpenCart) {
                    Image(systemName: AppImages.cart)
                        .overlay(alignment: .topTrailing) {
                            if dependencies.cartViewModel.itemCount > 0 {
                                Circle()
                                    .fill(AppColors.primary)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 3, y: -2)
                            }
                        }
                }
                .accessibilityLabel(Text("My Cart"))
                .accessibilityValue(Text("\(dependencies.cartViewModel.itemCount) items"))
            }
        }
        .toast(message: $toastMessage)
        .task { await catalog.loadIfNeeded() }
        .onAppear { isFieldFocused = true }
        // Remember a query once the customer is done typing (keyboard dismissed or result opened).
        .onChange(of: isFieldFocused) { _, isFocused in
            if !isFocused { viewModel.record(catalog.searchText) }
        }
    }

    // MARK: Search field

    private var searchRow: some View {
        HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
            HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
                Image(systemName: AppImages.search)
                    .foregroundStyle(AppColors.textSecondary)
                    .accessibilityHidden(true)

                TextField("Search for products…", text: $catalog.searchText)
                    .focused($isFieldFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit { viewModel.record(catalog.searchText) }
                    .accessibilityIdentifier("search.field")

                if !catalog.searchText.isEmpty {
                    Button {
                        catalog.searchText = ""
                    } label: {
                        Image(systemName: AppImages.clear)
                            .foregroundStyle(AppColors.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Clear Search"))
                }
            }
            .font(AppFont.callout)
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 48)
            .background(AppColors.surface, in: Capsule())
            .overlay(Capsule().strokeBorder(isFieldFocused ? AppColors.primary.opacity(0.6) : AppColors.hairline, lineWidth: 1))

            Menu {
                Picker("Sort By", selection: $catalog.sort) {
                    ForEach(ProductSort.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(catalog.sort == .featured ? AppColors.textPrimary : AppColors.onPrimary)
                    .frame(width: 48, height: 48)
                    .background(catalog.sort == .featured ? AppColors.surface : AppColors.primary, in: Circle())
                    .overlay(Circle().strokeBorder(AppColors.hairline, lineWidth: 1))
            }
            .accessibilityLabel(Text("Sort By"))
        }
    }

    // MARK: Recent searches

    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text("Recent Searches")
                    .font(AppFont.headline)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button("Clear All") {
                    withAnimation { viewModel.clearRecentSearches() }
                }
                .font(AppFont.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.primary)
            }
            .frame(minHeight: 44)

            ForEach(matchingRecentSearches, id: \.self) { search in
                HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
                    Button {
                        catalog.searchText = search
                        viewModel.record(search)
                        isFieldFocused = false
                    } label: {
                        HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(AppColors.textSecondary)
                            Text(search)
                                .foregroundStyle(AppColors.textPrimary)
                                .lineLimit(1)
                            Spacer()
                        }
                        .font(AppFont.callout)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation { viewModel.removeRecentSearch(search) }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.textTertiary)
                            .frame(width: 32, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Remove \(search)"))
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: Filters

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(ProductCategory.allCases) { category in
                    Button {
                        viewModel.toggleCategory(category)
                    } label: {
                        FilterChip(
                            title: category.title,
                            systemImage: category.systemImage,
                            isSelected: viewModel.selectedCategory == category
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    viewModel.isOnSaleOnly.toggle()
                } label: {
                    FilterChip(title: "On Sale", systemImage: AppImages.offers, isSelected: viewModel.isOnSaleOnly)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .sensoryFeedback(.selection, trigger: viewModel.selectedCategory)
        .sensoryFeedback(.selection, trigger: viewModel.isOnSaleOnly)
    }

    // MARK: Results

    @ViewBuilder
    private var resultsSection: some View {
        if !catalog.hasLoaded, let errorMessage = catalog.errorMessage {
            ErrorStateView(message: errorMessage) {
                Task { await catalog.loadProducts() }
            }
            .frame(minHeight: 280)
        } else if !catalog.hasLoaded {
            LoadingView(message: "Loading products…")
                .frame(height: 240)
        } else {
            let products = results
            VStack(alignment: .leading, spacing: AppSpacing.sm + AppSpacing.xs) {
                Group {
                    if catalog.isSearching {
                        Text("\(products.count) results")
                    } else {
                        Text("Popular")
                    }
                }
                .font(AppFont.headline)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal, AppSpacing.md)

                if products.isEmpty {
                    EmptyStateView(
                        title: "No Matching Products",
                        systemImage: AppImages.search,
                        message: "Try a different search or category."
                    )
                    .frame(minHeight: 280)
                } else {
                    LazyVGrid(columns: columns, spacing: AppSpacing.sm + AppSpacing.xs) {
                        ForEach(products) { product in
                            NavigationLink(value: product) {
                                SearchProductCard(
                                    product: product,
                                    isFavorite: dependencies.wishlistViewModel.contains(product),
                                    onToggleFavorite: { dependencies.wishlistViewModel.toggle(product) },
                                    onAddToCart: {
                                        dependencies.cartViewModel.add(product)
                                        toastMessage = String(localized: "\(product.name) added to your bag")
                                    }
                                )
                            }
                            .buttonStyle(.pressable)
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                }
            }
        }
    }
}

#Preview {
    let dependencies = DependencyContainer.preview
    NavigationStack {
        SearchView(
            catalog: dependencies.catalogViewModel,
            viewModel: dependencies.makeSearchViewModel(),
            onOpenCart: {}
        )
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(viewModel: dependencies.makeProductDetailViewModel(product: product))
        }
    }
    .environment(dependencies)
}

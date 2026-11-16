import SwiftUI

/// The shop screen: category chips, search, sort, and a grid of products.
struct HomeView: View {
    @State private var viewModel: ProductListViewModel
    @Environment(AppDependencies.self) private var dependencies

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    /// Creates the view with its view model.
    init(viewModel: ProductListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .background(AppColors.background)
                .navigationTitle("Shop")
                .searchable(text: $viewModel.searchText, prompt: "Search products")
                .toolbar { sortMenu }
                .navigationDestination(for: Product.self) { product in
                    ProductDetailView(viewModel: dependencies.makeProductDetailViewModel(product: product))
                }
                .alert("Something Went Wrong", isPresented: $viewModel.isErrorAlertPresented) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
                .task { await viewModel.loadIfNeeded() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if !viewModel.hasLoaded, let errorMessage = viewModel.errorMessage {
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.loadProducts() }
            }
        } else if !viewModel.hasLoaded {
            LoadingView(message: "Loading products…")
        } else if viewModel.products.isEmpty {
            EmptyStateView(
                title: "No Products Yet",
                systemImage: AppImages.shop,
                message: "New products are on the way. Pull to refresh or check back soon.",
                actionTitle: "Refresh"
            ) {
                Task { await viewModel.loadProducts() }
            }
        } else {
            catalog
        }
    }

    private var catalog: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                categoryChips

                if viewModel.visibleProducts.isEmpty {
                    EmptyStateView(
                        title: "No Matching Products",
                        systemImage: AppImages.search,
                        message: "Try a different search or category."
                    )
                    .padding(.top, AppSpacing.xl)
                } else {
                    LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                        ForEach(viewModel.visibleProducts) { product in
                            NavigationLink(value: product) {
                                ProductCardView(product: product)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("product.card")
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                }
            }
            .padding(.vertical, AppSpacing.sm)
        }
        .refreshable { await viewModel.loadProducts() }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                CategoryChip(
                    title: "All",
                    systemImage: AppImages.categoryAll,
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectedCategory = nil
                }

                ForEach(ProductCategory.allCases) { category in
                    CategoryChip(
                        title: category.title,
                        systemImage: category.systemImage,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.toggleCategory(category)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
    }

    @ToolbarContentBuilder
    private var sortMenu: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Picker("Sort By", selection: $viewModel.sort) {
                    ForEach(ProductSort.allCases) { sort in
                        Text(sort.title).tag(sort)
                    }
                }
            } label: {
                Label("Sort By", systemImage: AppImages.sort)
            }
        }
    }
}

#Preview("Catalog") {
    let dependencies = AppDependencies.preview
    HomeView(viewModel: dependencies.makeProductListViewModel())
        .environment(dependencies)
}

#Preview("Empty") {
    HomeView(viewModel: ProductListViewModel(productService: MockProductService(products: [], latency: .zero)))
        .environment(AppDependencies.preview)
}

#Preview("Khmer") {
    let dependencies = AppDependencies.preview
    HomeView(viewModel: dependencies.makeProductListViewModel())
        .environment(dependencies)
        .environment(\.locale, Locale(identifier: "km"))
}

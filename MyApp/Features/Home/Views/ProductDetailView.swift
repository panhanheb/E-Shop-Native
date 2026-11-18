import SwiftUI

/// Product details with quantity selection and an add-to-cart button.
struct ProductDetailView: View {
    @State private var viewModel: ProductDetailViewModel
    @Environment(DependencyContainer.self) private var dependencies

    private var isFavorite: Bool {
        dependencies.wishlistViewModel.contains(viewModel.product)
    }

    /// Creates the view with its view model.
    init(viewModel: ProductDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var product: Product { viewModel.product }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                ProductImageView(product: product, iconSize: AppFontSize.iconLarge * 1.5)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.xLarge))

                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                header
                Divider()
                description
                Divider()
                purchaseSection
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background)
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Button {
                        dependencies.wishlistViewModel.toggle(viewModel.product)
                    } label: {
                        Image(systemName: isFavorite ? AppImages.favoriteFilled : AppImages.favorite)
                            .foregroundStyle(isFavorite ? AppColors.rose : AppColors.textPrimary)
                    }
                    .accessibilityLabel(isFavorite ? Text("Remove from Wishlist") : Text("Add to Wishlist"))
                    .accessibilityIdentifier("productDetail.favorite")
                }
            }
        }
        .refreshable { await viewModel.refresh() }
        .task { await viewModel.refresh() }
        .alert("Added to Cart", isPresented: $viewModel.isAddedConfirmationPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(viewModel.lastAddedQuantity) × \(product.name)")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Label(product.category.title, systemImage: product.category.systemImage)
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textSecondary)
            Text(product.name)
                .font(AppFont.display)
            Text(product.tagline)
                .font(AppFont.callout)
                .foregroundStyle(AppColors.textSecondary)
            RatingView(rating: product.rating, reviewCount: product.reviewCount, starSize: 13)
            PriceText(product.price, originalPrice: product.originalPrice, font: AppFont.title)
            stockLabel
        }
    }

    @ViewBuilder
    private var stockLabel: some View {
        if !viewModel.isInStock {
            Text("Out of Stock")
                .font(AppFont.callout)
                .foregroundStyle(AppColors.danger)
        } else if product.stock <= 10 {
            Text("Only \(product.stock) left in stock")
                .font(AppFont.callout)
                .foregroundStyle(AppColors.warning)
        } else {
            Text("In Stock")
                .font(AppFont.callout)
                .foregroundStyle(AppColors.success)
        }
    }

    private var description: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Description")
                .font(AppFont.headline)
            Text(product.details)
                .font(AppFont.body)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var purchaseSection: some View {
        VStack(spacing: AppSpacing.md) {
            if viewModel.isInStock {
                HStack {
                    Text("Quantity")
                        .font(AppFont.headline)
                    Spacer()
                    QuantityStepper(
                        quantity: viewModel.quantity,
                        canDecrease: viewModel.canDecreaseQuantity,
                        canIncrease: viewModel.canIncreaseQuantity,
                        onDecrease: { viewModel.decreaseQuantity() },
                        onIncrease: { viewModel.increaseQuantity() }
                    )
                }

                HStack {
                    Text("Total")
                        .font(AppFont.headline)
                    Spacer()
                    Text(viewModel.totalPrice, format: .currency(code: AppCurrency.code))
                        .font(AppFont.headline)
                }
            }

            PrimaryButton(viewModel.isInStock ? "Add to Cart" : "Out of Stock") {
                viewModel.addToCart()
            }
            .disabled(!viewModel.isInStock)
            .accessibilityIdentifier("productDetail.addToCart")
        }
    }
}

#Preview {
    let dependencies = DependencyContainer.preview
    NavigationStack {
        ProductDetailView(viewModel: dependencies.makeProductDetailViewModel(product: .mock))
    }
    .environment(dependencies)
}

#Preview("Out of Stock") {
    let dependencies = DependencyContainer.preview
    NavigationStack {
        ProductDetailView(viewModel: dependencies.makeProductDetailViewModel(product: .mockOutOfStock))
    }
    .environment(dependencies)
}

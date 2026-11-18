import SwiftUI

/// Product details: large image, name, rating, price and stock, description, and a sticky
/// bottom bar with the quantity stepper, total, and Add to Cart.
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

    private var discountPercent: Int? {
        guard let originalPrice = product.originalPrice, originalPrice > product.price, originalPrice > 0 else { return nil }
        let fraction = (originalPrice - product.price) / originalPrice * 100
        return Int(NSDecimalNumber(decimal: fraction).doubleValue.rounded())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                ProductImageView(product: product, iconSize: AppFontSize.iconLarge * 1.6)
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.xLarge, style: .continuous))
                    .overlay(alignment: .topLeading) { discountBadge }

                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                header
                detailsCard
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) { purchaseBar }
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
                            .foregroundStyle(isFavorite ? AppColors.primary : AppColors.textPrimary)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: isFavorite)
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

    // MARK: Sections

    @ViewBuilder
    private var discountBadge: some View {
        if viewModel.isInStock, let discountPercent {
            Text("\(discountPercent)% OFF")
                .font(AppFont.captionEmphasized)
                .foregroundStyle(AppColors.onPrimary)
                .padding(.horizontal, AppSpacing.sm + AppSpacing.xxs)
                .padding(.vertical, AppSpacing.xs + AppSpacing.xxs)
                .background(AppColors.primary, in: Capsule())
                .padding(AppSpacing.md)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                Label(product.category.title, systemImage: product.category.systemImage)
                    .font(AppFont.captionEmphasized)
                    .foregroundStyle(product.category.tint)
                    .padding(.horizontal, AppSpacing.sm + AppSpacing.xxs)
                    .padding(.vertical, AppSpacing.xs + AppSpacing.xxs)
                    .background(product.category.tint.opacity(0.12), in: Capsule())
                stockPill
            }

            Text(product.name)
                .font(AppFont.title)
                .foregroundStyle(AppColors.textPrimary)

            Text(product.tagline)
                .font(AppFont.callout)
                .foregroundStyle(AppColors.textSecondary)

            HStack(spacing: AppSpacing.sm) {
                RatingView(rating: product.rating, reviewCount: product.reviewCount, starSize: 13)
                Text(product.rating, format: .number.precision(.fractionLength(1)))
                    .font(AppFont.subheadline.weight(.semibold))
            }

            PriceText(product.price, originalPrice: product.originalPrice, font: Font.title.weight(.bold))
                .padding(.top, AppSpacing.xs)
        }
    }

    private var stockPill: some View {
        let (text, color): (LocalizedStringKey, Color) = if !viewModel.isInStock {
            ("Out of Stock", AppColors.danger)
        } else if product.stock <= 10 {
            ("Only \(product.stock) left", AppColors.warning)
        } else {
            ("In Stock", AppColors.success)
        }
        return Label(text, systemImage: "circle.fill")
            .labelStyle(StatusDotLabelStyle())
            .font(AppFont.captionEmphasized)
            .foregroundStyle(color)
            .padding(.horizontal, AppSpacing.sm + AppSpacing.xxs)
            .padding(.vertical, AppSpacing.xs + AppSpacing.xxs)
            .background(color.opacity(0.12), in: Capsule())
    }

    private var detailsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Description")
                        .font(AppFont.headline)
                    Text(product.details)
                        .font(AppFont.callout)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                HStack(spacing: AppSpacing.md) {
                    perk(AppImages.orders, "Free delivery from \(ShippingPolicy.freeShippingThreshold, format: .currency(code: AppCurrency.code))")
                    perk(AppImages.success, "100% authentic")
                }
            }
        }
    }

    private func perk(_ systemImage: String, _ title: LocalizedStringKey) -> some View {
        HStack(spacing: AppSpacing.sm) {
            IconTile(systemImage: systemImage, size: 32)
            Text(title)
                .font(AppFont.caption.weight(.medium))
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Bottom bar

    private var purchaseBar: some View {
        VStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
            if viewModel.isInStock {
                HStack {
                    QuantityStepper(
                        quantity: viewModel.quantity,
                        canDecrease: viewModel.canDecreaseQuantity,
                        canIncrease: viewModel.canIncreaseQuantity,
                        onDecrease: { viewModel.decreaseQuantity() },
                        onIncrease: { viewModel.increaseQuantity() }
                    )
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("Total")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        Text(viewModel.totalPrice, format: .currency(code: AppCurrency.code))
                            .font(AppFont.title.monospacedDigit())
                            .contentTransition(.numericText())
                            .animation(.snappy, value: viewModel.totalPrice)
                    }
                    .accessibilityElement(children: .combine)
                }
            }

            PrimaryButton(
                viewModel.isInStock ? "Add to Cart" : "Out of Stock",
                systemImage: viewModel.isInStock ? AppImages.addToCart : nil
            ) {
                viewModel.addToCart()
            }
            .disabled(!viewModel.isInStock)
            .accessibilityIdentifier("productDetail.addToCart")
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm + AppSpacing.xxs)
        .padding(.bottom, AppSpacing.sm)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }
}

/// Small colored dot followed by the title, for status pills.
private struct StatusDotLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: AppSpacing.xs + AppSpacing.xxs) {
            configuration.icon
                .font(.system(size: 6))
            configuration.title
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

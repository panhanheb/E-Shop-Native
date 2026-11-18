import SwiftUI

/// Modal checkout: delivery address, payment method, order summary, and a sticky Place Order bar.
struct CheckoutView: View {
    @State private var viewModel: CheckoutViewModel
    @Environment(\.dismiss) private var dismiss

    /// Creates the view with its view model.
    init(viewModel: CheckoutViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let order = viewModel.placedOrder {
                    OrderConfirmationView(order: order) { dismiss() }
                } else {
                    form
                }
            }
            .navigationTitle(viewModel.placedOrder == nil ? Text("Checkout") : Text("Order Placed"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.placedOrder == nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .disabled(viewModel.isPlacingOrder)
                    }
                }
            }
            .interactiveDismissDisabled(viewModel.isPlacingOrder)
        }
    }

    private var form: some View {
        Form {
            if let errorMessage = viewModel.errorMessage {
                Section {
                    ErrorBanner(message: errorMessage)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section {
                field(AppImages.person) {
                    TextField("Full Name", text: $viewModel.fullName)
                        .textContentType(.name)
                }
                field(AppImages.phone) {
                    TextField("Phone Number", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .accessibilityIdentifier("checkout.phone")
                }
                field(AppImages.address) {
                    TextField("Street Address", text: $viewModel.street)
                        .textContentType(.fullStreetAddress)
                        .accessibilityIdentifier("checkout.street")
                }
                field("building.2") {
                    TextField("City / Province", text: $viewModel.city)
                        .textContentType(.addressCity)
                        .accessibilityIdentifier("checkout.city")
                }
            } header: {
                Text("Delivery Address")
            } footer: {
                if let validationMessage = viewModel.validationMessage {
                    Text(validationMessage)
                        .foregroundStyle(AppColors.danger)
                }
            }

            Section("Payment Method") {
                ForEach(PaymentMethod.allCases) { method in
                    paymentRow(method)
                }
            }

            Section("Order Summary") {
                ForEach(viewModel.items) { item in
                    HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
                        ProductImageView(product: item.product, iconSize: 18)
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
                        VStack(alignment: .leading, spacing: 0) {
                            Text(item.product.name)
                                .font(AppFont.subheadline.weight(.medium))
                                .lineLimit(1)
                            Text("Qty \(item.quantity)")
                                .font(AppFont.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                        Text(item.product.price * Decimal(item.quantity), format: .currency(code: AppCurrency.code))
                            .font(AppFont.subheadline.monospacedDigit())
                    }
                }
                PriceSummaryView(subtotal: viewModel.subtotal, shippingFee: viewModel.shippingFee, total: viewModel.total)
                    .padding(.vertical, AppSpacing.xs)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) { placeOrderBar }
    }

    private func field<Content: View>(_ systemImage: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
            Image(systemName: systemImage)
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: AppFontSize.iconSmall)
                .accessibilityHidden(true)
            content()
        }
    }

    private func paymentRow(_ method: PaymentMethod) -> some View {
        let isSelected = viewModel.paymentMethod == method
        return Button {
            viewModel.paymentMethod = method
        } label: {
            HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
                IconTile(systemImage: method.systemImage, tint: isSelected ? AppColors.primary : AppColors.textSecondary)
                Text(method.title)
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? AppColors.primary : AppColors.textTertiary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: viewModel.paymentMethod)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var placeOrderBar: some View {
        HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Total")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
                Text(viewModel.total, format: .currency(code: AppCurrency.code))
                    .font(AppFont.title.monospacedDigit())
            }
            .accessibilityElement(children: .combine)

            PrimaryButton("Place Order", isLoading: viewModel.isPlacingOrder) {
                Task { await viewModel.placeOrder() }
            }
            .disabled(!viewModel.canPlaceOrder)
            .accessibilityIdentifier("checkout.placeOrder")
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm + AppSpacing.xxs)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }
}

#Preview {
    CheckoutView(
        viewModel: CheckoutViewModel(
            items: [CartItem(product: .mock, quantity: 1), CartItem(product: Product.mocks[2], quantity: 2)],
            fullName: User.mock.name,
            orderService: MockOrderService(latency: .zero),
            onOrderPlaced: { _ in }
        )
    )
}

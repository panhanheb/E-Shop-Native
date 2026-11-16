import SwiftUI

/// Modal checkout: delivery address, payment method, order summary, and place order.
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
                TextField("Full Name", text: $viewModel.fullName)
                    .textContentType(.name)
                TextField("Phone Number", text: $viewModel.phone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .accessibilityIdentifier("checkout.phone")
                TextField("Street Address", text: $viewModel.street)
                    .textContentType(.fullStreetAddress)
                    .accessibilityIdentifier("checkout.street")
                TextField("City / Province", text: $viewModel.city)
                    .textContentType(.addressCity)
                    .accessibilityIdentifier("checkout.city")
            } header: {
                Text("Delivery Address")
            } footer: {
                if let validationMessage = viewModel.validationMessage {
                    Text(validationMessage)
                        .foregroundStyle(AppColors.danger)
                }
            }

            Section("Payment Method") {
                Picker("Payment Method", selection: $viewModel.paymentMethod) {
                    ForEach(PaymentMethod.allCases) { method in
                        Label(method.title, systemImage: method.systemImage)
                            .tag(method)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section("Order Summary") {
                ForEach(viewModel.items) { item in
                    HStack {
                        Text("\(item.quantity) × \(item.product.name)")
                            .font(AppFont.callout)
                        Spacer()
                        Text(item.product.price * Decimal(item.quantity), format: .currency(code: AppCurrency.code))
                            .font(AppFont.callout)
                    }
                }
                PriceSummaryView(subtotal: viewModel.subtotal, shippingFee: viewModel.shippingFee, total: viewModel.total)
            }

            Section {
                PrimaryButton("Place Order", isLoading: viewModel.isPlacingOrder) {
                    Task { await viewModel.placeOrder() }
                }
                .disabled(!viewModel.canPlaceOrder)
                .accessibilityIdentifier("checkout.placeOrder")
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
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

import SwiftUI

/// The shopping cart with quantity controls, totals, and a checkout button.
struct CartView: View {
    /// Shared app-wide cart.
    let cart: CartViewModel
    /// Shows a Close button when the cart is presented as a sheet.
    var onClose: (() -> Void)?
    /// Takes the customer back to shopping from the empty state.
    let onStartShopping: () -> Void

    @Environment(AppDependencies.self) private var dependencies
    @State private var isPresentingCheckout = false
    @State private var isConfirmingClear = false

    var body: some View {
        NavigationStack {
            Group {
                if cart.isEmpty {
                    EmptyStateView(
                        title: "Your Cart Is Empty",
                        systemImage: AppImages.cart,
                        message: "Browse the shop and add something you like.",
                        actionTitle: "Start Shopping"
                    ) {
                        onStartShopping()
                    }
                } else {
                    cartList
                }
            }
            .background(AppColors.background)
            .navigationTitle("Cart")
            .toolbar {
                if let onClose {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { onClose() }
                            .accessibilityIdentifier("cart.close")
                    }
                }
                if !cart.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear", role: .destructive) {
                            isConfirmingClear = true
                        }
                    }
                }
            }
            .confirmationDialog(
                "Remove all items from your cart?",
                isPresented: $isConfirmingClear,
                titleVisibility: .visible
            ) {
                Button("Remove All", role: .destructive) { cart.clear() }
            }
            .sheet(isPresented: $isPresentingCheckout) {
                CheckoutView(viewModel: dependencies.makeCheckoutViewModel())
            }
        }
    }

    private var cartList: some View {
        List {
            Section {
                ForEach(cart.items) { item in
                    CartItemRow(
                        item: item,
                        lineTotal: cart.lineTotal(for: item),
                        canIncrement: cart.canIncrement(item),
                        onIncrement: { cart.increment(item) },
                        onDecrement: { cart.decrement(item) }
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            cart.remove(item)
                        } label: {
                            Label("Remove", systemImage: AppImages.delete)
                        }
                    }
                }
            }

            Section {
                if let remaining = cart.amountUntilFreeShipping {
                    Text("Add \(remaining.formatted(.currency(code: AppCurrency.code))) more for free shipping.")
                        .font(AppFont.callout)
                        .foregroundStyle(AppColors.info)
                }
                PriceSummaryView(subtotal: cart.subtotal, shippingFee: cart.shippingFee, total: cart.total)
            }
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryButton("Checkout") {
                isPresentingCheckout = true
            }
            .accessibilityIdentifier("cart.checkout")
            .padding(AppSpacing.md)
            .background(.bar)
        }
    }
}

#Preview("With Items") {
    CartView(
        cart: CartViewModel(items: [
            CartItem(product: Product.mocks[0], quantity: 1),
            CartItem(product: Product.mocks[2], quantity: 2)
        ]),
        onStartShopping: {}
    )
    .environment(AppDependencies.preview)
}

#Preview("Empty") {
    CartView(cart: CartViewModel(), onStartShopping: {})
        .environment(AppDependencies.preview)
}

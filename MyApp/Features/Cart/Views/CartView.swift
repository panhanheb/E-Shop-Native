import SwiftUI

/// The shopping cart: free-shipping progress, item rows with quantity controls, totals,
/// and a sticky bar with the total and Checkout button.
struct CartView: View {
    /// Shared app-wide cart.
    let cart: CartViewModel
    /// Shows a Close button when the cart is presented as a sheet.
    var onClose: (() -> Void)?
    /// Takes the customer back to shopping from the empty state.
    let onStartShopping: () -> Void

    @Environment(DependencyContainer.self) private var dependencies
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .navigationTitle(cart.isEmpty ? Text("Cart") : Text("Cart (\(cart.itemCount))"))
            .navigationBarTitleDisplayMode(.inline)
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
                        .tint(AppColors.danger)
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
                freeShippingMeter
            }

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
            } footer: {
                Text("Swipe left on an item to remove it.")
            }

            Section("Order Summary") {
                PriceSummaryView(subtotal: cart.subtotal, shippingFee: cart.shippingFee, total: cart.total)
                    .padding(.vertical, AppSpacing.xs)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) { checkoutBar }
    }

    /// Progress toward free shipping, or a confirmation once it's reached.
    private var freeShippingMeter: some View {
        let threshold = NSDecimalNumber(decimal: ShippingPolicy.freeShippingThreshold).doubleValue
        let subtotal = NSDecimalNumber(decimal: cart.subtotal).doubleValue
        return VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                IconTile(
                    systemImage: AppImages.orders,
                    tint: cart.amountUntilFreeShipping == nil ? AppColors.success : AppColors.primary,
                    size: 32
                )
                if let remaining = cart.amountUntilFreeShipping {
                    Text("Add **\(remaining.formatted(.currency(code: AppCurrency.code)))** more for free shipping")
                } else {
                    Text("You've unlocked **free shipping**")
                }
            }
            .font(AppFont.subheadline)

            ProgressView(value: min(subtotal, threshold), total: threshold)
                .tint(cart.amountUntilFreeShipping == nil ? AppColors.success : AppColors.primary)
                .animation(.easeInOut, value: subtotal)
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var checkoutBar: some View {
        HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Total")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
                Text(cart.total, format: .currency(code: AppCurrency.code))
                    .font(AppFont.title.monospacedDigit())
                    .contentTransition(.numericText())
                    .animation(.snappy, value: cart.total)
            }
            .accessibilityElement(children: .combine)

            PrimaryButton("Checkout") {
                isPresentingCheckout = true
            }
            .accessibilityIdentifier("cart.checkout")
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm + AppSpacing.xxs)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
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
    .environment(DependencyContainer.preview)
}

#Preview("Empty") {
    CartView(cart: CartViewModel(), onStartShopping: {})
        .environment(DependencyContainer.preview)
}

import SwiftUI

/// Success screen shown after an order is placed.
struct OrderConfirmationView: View {
    let order: Order
    /// Closes checkout.
    let onDone: () -> Void

    @State private var isShowingCheck = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 88, height: 88)
                    .background(AppColors.success, in: Circle())
                    .padding(AppSpacing.sm + AppSpacing.xs)
                    .background(AppColors.success.opacity(0.15), in: Circle())
                    .scaleEffect(isShowingCheck ? 1 : 0.5)
                    .opacity(isShowingCheck ? 1 : 0)
                    .accessibilityHidden(true)
                    .padding(.top, AppSpacing.xl)

                VStack(spacing: AppSpacing.sm) {
                    Text("Thank You!")
                        .font(AppFont.largeTitle)
                    Text("Your order \(order.number) has been placed.")
                        .font(AppFont.callout)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                CardView {
                    VStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
                        detailRow("Order Number") {
                            Text(order.number).fontWeight(.semibold)
                        }
                        detailRow("Status") {
                            OrderStatusBadge(status: order.status)
                        }
                        detailRow("Payment") {
                            Text(order.paymentMethod.title)
                        }
                        detailRow("Deliver To") {
                            Text(order.shippingAddress.city)
                        }
                        Divider()
                            .padding(.vertical, AppSpacing.xxs)
                        PriceSummaryView(subtotal: order.subtotal, shippingFee: order.shippingFee, total: order.total)
                    }
                }

                Label("You can track this order in the Orders tab.", systemImage: "info.circle")
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColors.textSecondary)

                PrimaryButton("Continue Shopping", action: { onDone() })
                    .accessibilityIdentifier("checkout.done")
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background)
        .sensoryFeedback(.success, trigger: isShowingCheck)
        .onAppear {
            withAnimation(.spring(duration: 0.5, bounce: 0.4)) { isShowingCheck = true }
        }
    }

    private func detailRow<Value: View>(_ title: LocalizedStringKey, @ViewBuilder value: () -> Value) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            value()
                .foregroundStyle(AppColors.textPrimary)
        }
        .font(AppFont.subheadline)
    }
}

#Preview {
    OrderConfirmationView(order: .mock, onDone: {})
}

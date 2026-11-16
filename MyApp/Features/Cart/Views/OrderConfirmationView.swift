import SwiftUI

/// Success screen shown after an order is placed.
struct OrderConfirmationView: View {
    let order: Order
    /// Closes checkout.
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                Image(systemName: AppImages.success)
                    .font(AppFont.icon(AppFontSize.iconLarge))
                    .foregroundStyle(AppColors.success)
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
                    VStack(spacing: AppSpacing.md) {
                        LabeledContent("Payment") {
                            Text(order.paymentMethod.title)
                        }
                        LabeledContent("Deliver To") {
                            Text(order.shippingAddress.city)
                        }
                        Divider()
                        PriceSummaryView(subtotal: order.subtotal, shippingFee: order.shippingFee, total: order.total)
                    }
                }

                Text("You can track this order in the Orders tab.")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)

                PrimaryButton("Continue Shopping", action: { onDone() })
                    .accessibilityIdentifier("checkout.done")
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background)
    }
}

#Preview {
    OrderConfirmationView(order: .mock, onDone: {})
}

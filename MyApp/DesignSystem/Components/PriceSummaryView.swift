import SwiftUI

/// Subtotal, shipping, and total rows used in the cart, checkout, and order details.
struct PriceSummaryView: View {
    let subtotal: Decimal
    let shippingFee: Decimal
    let total: Decimal

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            LabeledContent("Subtotal") {
                Text(subtotal, format: .currency(code: AppCurrency.code))
            }
            LabeledContent("Shipping") {
                if shippingFee == 0 {
                    Text("Free")
                        .foregroundStyle(AppColors.success)
                } else {
                    Text(shippingFee, format: .currency(code: AppCurrency.code))
                }
            }
            Divider()
            LabeledContent("Total") {
                Text(total, format: .currency(code: AppCurrency.code))
                    .font(AppFont.headline)
                    .foregroundStyle(AppColors.textPrimary)
            }
            .font(AppFont.headline)
        }
        .font(AppFont.callout)
    }
}

#Preview {
    PriceSummaryView(subtotal: 37.4, shippingFee: 2.5, total: 39.9)
        .padding()
}

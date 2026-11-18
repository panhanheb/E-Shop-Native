import SwiftUI

/// Subtotal, shipping, and total rows used in the cart, checkout, and order details.
struct PriceSummaryView: View {
    let subtotal: Decimal
    let shippingFee: Decimal
    let total: Decimal

    var body: some View {
        VStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
            row("Subtotal") {
                Text(subtotal, format: .currency(code: AppCurrency.code))
            }
            row("Shipping") {
                if shippingFee == 0 {
                    Text("Free")
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.success)
                } else {
                    Text(shippingFee, format: .currency(code: AppCurrency.code))
                }
            }

            Divider()
                .padding(.vertical, AppSpacing.xxs)

            HStack {
                Text("Total")
                    .font(AppFont.headline)
                Spacer()
                Text(total, format: .currency(code: AppCurrency.code))
                    .font(AppFont.title.monospacedDigit())
                    .foregroundStyle(AppColors.textPrimary)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private func row<Value: View>(_ title: LocalizedStringKey, @ViewBuilder value: () -> Value) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            value()
                .monospacedDigit()
                .foregroundStyle(AppColors.textPrimary)
        }
        .font(AppFont.subheadline)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PriceSummaryView(subtotal: 37.4, shippingFee: 2.5, total: 39.9)
        .padding()
}

import SwiftUI

/// A cart line: thumbnail, name, unit price, quantity stepper, and line total.
struct CartItemRow: View {
    let item: CartItem
    let lineTotal: Decimal
    let canIncrement: Bool
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            ProductImageView(product: item.product, iconSize: AppFontSize.iconMedium)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.small))

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(item.product.name)
                    .font(AppFont.callout)
                    .lineLimit(2)
                Text(item.product.price, format: .currency(code: AppCurrency.code))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)

                HStack {
                    QuantityStepper(
                        quantity: item.quantity,
                        canDecrease: true,
                        canIncrease: canIncrement,
                        onDecrease: onDecrement,
                        onIncrease: onIncrement
                    )
                    Spacer()
                    Text(lineTotal, format: .currency(code: AppCurrency.code))
                        .font(AppFont.headline)
                }
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview {
    List {
        CartItemRow(item: CartItem(product: .mock, quantity: 2), lineTotal: 119.98, canIncrement: true, onIncrement: {}, onDecrement: {})
    }
}

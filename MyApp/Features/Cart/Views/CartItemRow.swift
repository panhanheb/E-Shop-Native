import SwiftUI

/// A cart line: thumbnail, name, tagline, unit price, quantity stepper, and line total.
struct CartItemRow: View {
    let item: CartItem
    let lineTotal: Decimal
    let canIncrement: Bool
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm + AppSpacing.xs) {
            ProductImageView(product: item.product, iconSize: AppFontSize.iconMedium + 4)
                .frame(width: 76, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(item.product.name)
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                Text(item.product.tagline)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)

                HStack(alignment: .center) {
                    QuantityStepper(
                        quantity: item.quantity,
                        canDecrease: true,
                        canIncrease: canIncrement,
                        onDecrease: onDecrement,
                        onIncrease: onIncrement
                    )
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(lineTotal, format: .currency(code: AppCurrency.code))
                            .font(AppFont.price.monospacedDigit())
                        if item.quantity > 1 {
                            Text("\(item.product.price.formatted(.currency(code: AppCurrency.code))) each")
                                .font(.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
                .padding(.top, AppSpacing.xxs)
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

import SwiftUI

/// A row in the order history: number, date, item count, total, and status.
struct OrderRowView: View {
    /// The order to display.
    let order: Order

    private var itemCount: Int {
        order.items.reduce(0) { $0 + $1.quantity }
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(order.number)
                    .font(AppFont.headline)
                Text(order.createdAt, format: .dateTime.day().month().year())
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
                Text("\(itemCount) items")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                Text(order.total, format: .currency(code: AppCurrency.code))
                    .font(AppFont.headline)
                OrderStatusBadge(status: order.status)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview {
    List(Order.mocks) { OrderRowView(order: $0) }
}

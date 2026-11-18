import SwiftUI

/// A row in the order history: status icon, number, date and item count, total, and status badge.
struct OrderRowView: View {
    /// The order to display.
    let order: Order

    private var itemCount: Int {
        order.items.reduce(0) { $0 + $1.quantity }
    }

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.sm + AppSpacing.xs) {
            IconTile(systemImage: order.status.systemImage, tint: order.status.color, size: 44)

            VStack(alignment: .leading, spacing: AppSpacing.xxs + 1) {
                Text(order.number)
                    .font(AppFont.headline)
                Text("\(order.createdAt.formatted(.dateTime.day().month().year())) · \(itemCount) items")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
                OrderStatusBadge(status: order.status)
                    .padding(.top, AppSpacing.xxs)
            }

            Spacer(minLength: AppSpacing.sm)

            Text(order.total, format: .currency(code: AppCurrency.code))
                .font(AppFont.price.monospacedDigit())
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview {
    List(Order.mocks) { OrderRowView(order: $0) }
}

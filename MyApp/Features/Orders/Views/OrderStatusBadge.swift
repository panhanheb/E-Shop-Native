import SwiftUI

/// Capsule badge showing an order's status.
struct OrderStatusBadge: View {
    /// The status to display.
    let status: OrderStatus

    var body: some View {
        Text(status.title)
            .font(AppFont.captionEmphasized)
            .foregroundStyle(status.color)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(status.color.opacity(0.15), in: Capsule())
    }
}

#Preview {
    VStack {
        ForEach(OrderStatus.allCases, id: \.self) { OrderStatusBadge(status: $0) }
    }
}

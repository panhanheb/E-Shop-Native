import SwiftUI

/// Capsule badge showing an order's status with its icon.
struct OrderStatusBadge: View {
    /// The status to display.
    let status: OrderStatus

    var body: some View {
        Label(status.title, systemImage: status.systemImage)
            .font(AppFont.captionEmphasized)
            .foregroundStyle(status.color)
            .padding(.horizontal, AppSpacing.sm + AppSpacing.xxs)
            .padding(.vertical, AppSpacing.xs)
            .background(status.color.opacity(0.12), in: Capsule())
    }
}

#Preview {
    VStack {
        ForEach(OrderStatus.allCases, id: \.self) { OrderStatusBadge(status: $0) }
    }
}

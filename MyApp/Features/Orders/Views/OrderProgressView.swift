import SwiftUI

/// Horizontal tracker: Pending → Processing → Shipped → Delivered, with completed steps
/// filled in the brand color. Shows a single "Cancelled" notice for cancelled orders.
struct OrderProgressView: View {
    let status: OrderStatus

    private var currentIndex: Int {
        OrderStatus.trackedSteps.firstIndex(of: status) ?? 0
    }

    var body: some View {
        if status == .cancelled {
            Label("This order was cancelled.", systemImage: status.systemImage)
                .font(AppFont.subheadline.weight(.medium))
                .foregroundStyle(status.color)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(OrderStatus.trackedSteps.enumerated()), id: \.offset) { index, step in
                    stepView(step, index: index)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Order status"))
            .accessibilityValue(Text(status.title))
        }
    }

    private func stepView(_ step: OrderStatus, index: Int) -> some View {
        let isDone = index <= currentIndex
        return VStack(spacing: AppSpacing.xs + AppSpacing.xxs) {
            ZStack {
                // Connector lines to the neighbouring steps.
                HStack(spacing: 0) {
                    connector(isVisible: index > 0, isDone: isDone)
                    connector(isVisible: index < OrderStatus.trackedSteps.count - 1, isDone: index < currentIndex)
                }

                Image(systemName: isDone ? "checkmark" : step.systemImage)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isDone ? AppColors.onPrimary : AppColors.textTertiary)
                    .frame(width: 28, height: 28)
                    .background(isDone ? AppColors.primary : AppColors.surface, in: Circle())
                    .overlay(Circle().strokeBorder(isDone ? .clear : AppColors.border, lineWidth: 1.5))
            }

            Text(step.title)
                .font(.caption2.weight(index == currentIndex ? .bold : .medium))
                .foregroundStyle(isDone ? AppColors.textPrimary : AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private func connector(isVisible: Bool, isDone: Bool) -> some View {
        Rectangle()
            .fill(isVisible ? (isDone ? AppColors.primary : AppColors.border) : .clear)
            .frame(height: 2)
    }
}

#Preview {
    VStack(spacing: AppSpacing.xl) {
        ForEach(OrderStatus.allCases, id: \.self) { OrderProgressView(status: $0) }
    }
    .padding()
}

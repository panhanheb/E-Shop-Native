import SwiftUI

extension OrderStatus {
    /// Localized display name.
    var title: LocalizedStringKey {
        switch self {
        case .pending: "Pending"
        case .processing: "Processing"
        case .shipped: "Shipped"
        case .delivered: "Delivered"
        case .cancelled: "Cancelled"
        }
    }

    /// Badge color.
    var color: Color {
        switch self {
        case .pending: AppColors.warning
        case .processing: AppColors.info
        case .shipped: AppColors.primary
        case .delivered: AppColors.success
        case .cancelled: AppColors.textSecondary
        }
    }
}

extension OrderStatus {
    /// SF Symbol for badges and the progress tracker.
    var systemImage: String {
        switch self {
        case .pending: "clock"
        case .processing: "shippingbox"
        case .shipped: "truck.box"
        case .delivered: "checkmark.circle"
        case .cancelled: "xmark.circle"
        }
    }

    /// Steps shown in the order progress tracker, in order. Cancelled orders don't use the tracker.
    static let trackedSteps: [OrderStatus] = [.pending, .processing, .shipped, .delivered]
}

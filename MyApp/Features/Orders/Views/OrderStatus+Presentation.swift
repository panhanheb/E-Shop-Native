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

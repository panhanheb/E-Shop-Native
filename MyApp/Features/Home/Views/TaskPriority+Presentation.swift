import SwiftUI

extension TaskPriority {
    /// Localized display name.
    var title: LocalizedStringKey {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    /// Accent color used for badges.
    var color: Color {
        switch self {
        case .low: AppColors.info
        case .medium: AppColors.warning
        case .high: AppColors.danger
        }
    }
}

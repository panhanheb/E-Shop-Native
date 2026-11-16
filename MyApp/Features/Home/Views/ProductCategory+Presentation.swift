import SwiftUI

extension ProductCategory {
    /// Localized display name.
    var title: LocalizedStringKey {
        switch self {
        case .electronics: "Electronics"
        case .fashion: "Fashion"
        case .home: "Home & Living"
        case .beauty: "Beauty"
        case .sports: "Sports"
        }
    }

    /// SF Symbol for chips and image placeholders.
    var systemImage: String {
        switch self {
        case .electronics: AppImages.categoryElectronics
        case .fashion: AppImages.categoryFashion
        case .home: AppImages.categoryHome
        case .beauty: AppImages.categoryBeauty
        case .sports: AppImages.categorySports
        }
    }

    /// Tint for image placeholders.
    var tint: Color {
        switch self {
        case .electronics: AppColors.info
        case .fashion: AppColors.primary
        case .home: AppColors.warning
        case .beauty: AppColors.danger
        case .sports: AppColors.success
        }
    }
}

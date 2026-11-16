import SwiftUI

extension ProductCategory {
    /// Localized display name.
    var title: LocalizedStringKey {
        switch self {
        case .skincare: "Skincare"
        case .makeup: "Makeup"
        case .fragrance: "Fragrance"
        case .haircare: "Haircare"
        case .tools: "Tools"
        }
    }

    /// SF Symbol for category circles and image placeholders.
    var systemImage: String {
        switch self {
        case .skincare: AppImages.categorySkincare
        case .makeup: AppImages.categoryMakeup
        case .fragrance: AppImages.categoryFragrance
        case .haircare: AppImages.categoryHaircare
        case .tools: AppImages.categoryTools
        }
    }

    /// Accent for icons and image placeholders.
    var tint: Color {
        switch self {
        case .skincare: AppColors.gold
        case .makeup: AppColors.berry
        case .fragrance: AppColors.rose
        case .haircare: AppColors.cocoa
        case .tools: AppColors.lilac
        }
    }
}

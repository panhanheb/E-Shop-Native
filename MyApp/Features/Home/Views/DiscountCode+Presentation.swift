import SwiftUI

extension DiscountCode.Style {
    /// Card fill.
    var background: AnyShapeStyle {
        switch self {
        case .crimson: AnyShapeStyle(AppColors.primary.gradient)
        case .sunset: AnyShapeStyle(LinearGradient(colors: [Color(hex: 0xFF8A00), Color(hex: 0xF5B700)], startPoint: .top, endPoint: .bottom))
        case .lemon: AnyShapeStyle(Color(hex: 0xFFD54A).gradient)
        case .blush: AnyShapeStyle(AppColors.blush.gradient)
        }
    }

    /// Text and border color on the card.
    var foreground: Color {
        switch self {
        case .crimson, .sunset: .white
        case .lemon: Color(hex: 0x3A2A00)
        case .blush: AppColors.berry
        }
    }
}

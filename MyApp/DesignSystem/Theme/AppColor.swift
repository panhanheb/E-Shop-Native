import SwiftUI

/// Semantic color palette. Adapts automatically to light and dark mode.
enum AppColor {
    static let primary = Color.accentColor
    static let background = Color(uiColor: .systemGroupedBackground)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
    static let info = Color.blue
}

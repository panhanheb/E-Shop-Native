import SwiftUI

/// Semantic color palette. Use these instead of raw colors so the theme can change in one place.
/// System-based colors adapt automatically to light and dark mode.
enum AppColors {
    // MARK: Brand

    /// Main brand color (from `AccentColor` in the asset catalog).
    static let primary = Color.accentColor
    /// Secondary brand color.
    static let secondary = Color(hex: 0x5AC8FA)
    /// Content drawn on top of `primary` (button titles, avatar initials).
    static let onPrimary = Color.white

    // MARK: Backgrounds

    /// Screen background.
    static let background = Color(uiColor: .systemGroupedBackground)
    /// Cards, text fields, and other raised surfaces.
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)

    // MARK: Text

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(uiColor: .tertiaryLabel)

    // MARK: Lines

    static let border = Color(uiColor: .separator)
    static let divider = Color(uiColor: .opaqueSeparator)

    // MARK: Status

    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
    static let info = Color.blue
}

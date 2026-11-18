import SwiftUI

/// Semantic color palette. Use these instead of raw colors so the theme can change in one place.
/// Asset-catalog colors (`AccentColor`, `AppBackground`, `AppSurface`, `Blush`) have light and dark values.
enum AppColors {
    // MARK: Brand

    /// Main brand color: red (from `AccentColor` in the asset catalog).
    static let primary = Color.accentColor
    /// Very light tint of the brand color for chips, icon backgrounds, and highlighted rows.
    static let primarySoft = Color("Blush")
    /// Content drawn on top of `primary` (button titles, avatar initials).
    static let onPrimary = Color.white

    // MARK: Backgrounds

    /// Screen background: neutral light gray (black in Dark Mode).
    static let background = Color("AppBackground")
    /// Cards, text fields, and other raised surfaces.
    static let surface = Color("AppSurface")

    // MARK: Text

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(uiColor: .tertiaryLabel)

    // MARK: Lines and shadows

    static let border = Color(uiColor: .separator)
    /// Hairline outline around cards and inputs.
    static let hairline = Color(uiColor: .separator).opacity(0.5)
    /// Very soft shadow for floating cards.
    static let shadow = Color.black.opacity(0.05)

    // MARK: Status

    static let success = Color(hex: 0x1F9D55)
    static let warning = Color(hex: 0xE8890C)
    static let danger = Color(hex: 0xD92D20)
    static let info = Color(hex: 0x2E6BE6)
    /// Rating stars.
    static let star = Color(hex: 0xF5A623)

    // MARK: Accents (category icons)

    static let accentAmber = Color(hex: 0xE8890C)
    static let accentPink = Color(hex: 0xE0457B)
    static let accentViolet = Color(hex: 0x7C5CD6)
    static let accentTeal = Color(hex: 0x14A38B)
    static let accentBlue = Color(hex: 0x2E6BE6)
}

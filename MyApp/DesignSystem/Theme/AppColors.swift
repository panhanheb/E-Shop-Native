import SwiftUI

/// Semantic color palette. Use these instead of raw colors so the theme can change in one place.
/// Asset-catalog colors (`AccentColor`, `AppBackground`, `AppSurface`, `Blush`) have light and dark values.
enum AppColors {
    // MARK: Brand

    /// Main brand color: warm orange (from `AccentColor` in the asset catalog).
    static let primary = Color.accentColor
    /// Soft tint of the brand color for icon backgrounds and highlights.
    static let primarySoft = Color.accentColor.opacity(0.14)
    /// Secondary brand color: rose gold.
    static let secondary = Color(hex: 0xC99A7B)
    /// Content drawn on top of `primary` (button titles, avatar initials).
    static let onPrimary = Color.white

    // MARK: Backgrounds

    /// Screen background: warm cream.
    static let background = Color("AppBackground")
    /// Cards, text fields, and other raised surfaces.
    static let surface = Color("AppSurface")
    /// Pink-peach used for banners and category circles.
    static let blush = Color("Blush")

    // MARK: Text

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(uiColor: .tertiaryLabel)

    // MARK: Lines and shadows

    static let border = Color(uiColor: .separator)
    static let divider = Color(uiColor: .opaqueSeparator)
    /// Very soft shadow for floating cards.
    static let shadow = Color.black.opacity(0.06)

    // MARK: Status

    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
    static let info = Color.blue
    /// Rating stars.
    static let star = Color(hex: 0xF5A623)

    // MARK: Beauty palette (category accents)

    static let gold = Color(hex: 0xC9965B)
    static let rose = Color(hex: 0xD8707E)
    static let berry = Color(hex: 0xB0305A)
    static let lilac = Color(hex: 0x9C89C9)
    static let cocoa = Color(hex: 0x8D6E63)
}

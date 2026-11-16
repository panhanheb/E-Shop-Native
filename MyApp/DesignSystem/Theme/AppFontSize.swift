import CoreGraphics

/// Point sizes for icons and custom fonts.
///
/// Text sizes match Apple's default Dynamic Type sizes (Large setting). Use them with
/// `AppFont.brand(_:size:relativeTo:)` so custom fonts still scale. Icon sizes are fixed.
enum AppFontSize {
    // MARK: Text

    static let caption: CGFloat = 12
    static let footnote: CGFloat = 13
    static let callout: CGFloat = 16
    static let body: CGFloat = 17
    static let headline: CGFloat = 17
    static let title: CGFloat = 22
    static let largeTitle: CGFloat = 34

    // MARK: Icons

    /// Leading icons in text fields.
    static let iconSmall: CGFloat = 20
    /// Row icons such as the completion toggle.
    static let iconMedium: CGFloat = 24
    /// Hero icons on auth screens.
    static let iconLarge: CGFloat = 64

    /// Ratio of avatar initials to avatar diameter.
    static let avatarInitialsRatio: CGFloat = 0.38
}

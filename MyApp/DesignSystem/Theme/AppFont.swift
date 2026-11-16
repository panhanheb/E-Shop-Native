import SwiftUI

/// Typography scale built on Dynamic Type text styles, so text follows the user's size setting.
enum AppFont {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title2.weight(.semibold)
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let captionEmphasized = Font.caption.weight(.semibold)
    /// Elegant serif for banner headlines (e.g. "Glow Naturally, Shine Beautifully").
    static let display = Font.system(.title, design: .serif).weight(.medium)
    /// Bold section headings such as "Best Sellers".
    static let sectionTitle = Font.title3.weight(.bold)

    /// Fixed-size system font for icons (does not scale with Dynamic Type).
    static func icon(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    /// A brand font that scales with Dynamic Type.
    /// Add the font file to the target and list it under `UIAppFonts` in Info.plist first.
    /// Example: `AppFont.brand("Inter-SemiBold", size: AppFontSize.title, relativeTo: .title2)`
    static func brand(_ name: String, size: CGFloat, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        .custom(name, size: size, relativeTo: textStyle)
    }
}

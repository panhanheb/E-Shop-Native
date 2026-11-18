import SwiftUI

/// Typography scale built on Dynamic Type text styles, so text follows the user's size setting.
enum AppFont {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title2.weight(.bold)
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let captionEmphasized = Font.caption.weight(.semibold)
    /// Banner and hero headlines.
    static let display = Font.title2.weight(.heavy)
    /// Section headings such as "Trending".
    static let sectionTitle = Font.title3.weight(.bold)
    /// Prices on cards and summaries.
    static let price = Font.headline.weight(.bold)

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

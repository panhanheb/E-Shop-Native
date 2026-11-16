import SwiftUI

/// Typography scale built on Dynamic Type text styles.
enum AppFont {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title2.weight(.semibold)
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let caption = Font.caption
    static let captionEmphasized = Font.caption.weight(.semibold)
}

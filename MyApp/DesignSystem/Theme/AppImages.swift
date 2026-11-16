import Foundation

/// Central list of image names used in the app.
///
/// SF Symbols are used with `Image(systemName:)` / `Label(_:systemImage:)`.
/// Asset catalog images are used with `Image(_:)`.
enum AppImages {
    // MARK: Tabs

    static let tasks = "checklist"
    static let profile = "person.crop.circle"
    static let settings = "gearshape"

    // MARK: Form fields

    static let person = "person"
    static let email = "envelope"
    static let password = "lock"
    static let confirmPassword = "lock.rotation"

    // MARK: Actions

    static let add = "plus"
    static let delete = "trash"
    static let search = "magnifyingglass"
    static let filter = "line.3.horizontal.decrease.circle"
    static let filterActive = "line.3.horizontal.decrease.circle.fill"
    static let checkmark = "checkmark"
    static let undo = "arrow.uturn.backward"
    static let signOut = "rectangle.portrait.and.arrow.right"

    // MARK: Status

    static let circle = "circle"
    static let checkmarkCircleFilled = "checkmark.circle.fill"
    static let calendar = "calendar"
    static let warning = "exclamationmark.triangle"
    static let warningFilled = "exclamationmark.triangle.fill"
    static let profileMissing = "person.crop.circle.badge.questionmark"
    static let privacy = "hand.raised"
    static let language = "globe"

    // MARK: Asset catalog
    // Add an image set to Resources/Assets.xcassets with the same name, then use `Image(AppImages.logo)`.

    static let logo = "AppLogo"
}

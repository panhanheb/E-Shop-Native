import Foundation

/// Central list of image names used in the app.
///
/// SF Symbols are used with `Image(systemName:)` / `Label(_:systemImage:)`.
/// Asset catalog images are used with `Image(_:)`.
enum AppImages {
    // MARK: Brand

    static let brand = "sparkles"

    // MARK: Tabs

    static let home = "house"
    static let categories = "square.grid.2x2"
    static let wishlist = "heart"
    static let orders = "shippingbox"
    static let profile = "person"
    static let settings = "gearshape"

    // MARK: Header

    static let menu = "line.3.horizontal"
    static let notifications = "bell"
    static let cart = "bag"

    // MARK: Form fields

    static let person = "person"
    static let email = "envelope"
    static let password = "lock"
    static let confirmPassword = "lock.rotation"
    static let phone = "phone"
    static let address = "mappin.and.ellipse"

    // MARK: Actions

    static let add = "plus"
    static let remove = "minus"
    static let delete = "trash"
    static let search = "magnifyingglass"
    static let filter = "line.3.horizontal.decrease"
    static let sort = "arrow.up.arrow.down"
    static let arrowRight = "arrow.right"
    static let chevronRight = "chevron.right"
    static let clear = "xmark.circle.fill"
    static let addToCart = "bag.badge.plus"
    static let favorite = "heart"
    static let favoriteFilled = "heart.fill"
    static let signOut = "rectangle.portrait.and.arrow.right"

    // MARK: Product categories

    static let categorySkincare = "drop.fill"
    static let categoryMakeup = "paintbrush.pointed.fill"
    static let categoryFragrance = "sparkles"
    static let categoryHaircare = "scissors"
    static let categoryTools = "wand.and.stars"
    static let offers = "tag.fill"

    // MARK: Payment

    static let paymentCash = "banknote"
    static let paymentQR = "qrcode"
    static let paymentCard = "creditcard"

    // MARK: Status

    static let star = "star.fill"
    static let starHalf = "star.leadinghalf.filled"
    static let starEmpty = "star"
    static let success = "checkmark.seal.fill"
    static let warning = "exclamationmark.triangle"
    static let warningFilled = "exclamationmark.triangle.fill"
    static let profileMissing = "person.crop.circle.badge.questionmark"
    static let privacy = "hand.raised"
    static let language = "globe"

    // MARK: Asset catalog
    // Add an image set to Resources/Assets.xcassets with the same name, then use `Image(AppImages.logo)`.

    static let logo = "AppLogo"
}

import Foundation

/// Central list of image names used in the app.
///
/// SF Symbols are used with `Image(systemName:)` / `Label(_:systemImage:)`.
/// Asset catalog images are used with `Image(_:)`.
enum AppImages {
    // MARK: Brand

    static let brand = "bag.fill"

    // MARK: Tabs

    static let shop = "storefront"
    static let cart = "cart"
    static let orders = "shippingbox"
    static let profile = "person.crop.circle"
    static let settings = "gearshape"

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
    static let sort = "arrow.up.arrow.down"
    static let addToCart = "cart.badge.plus"
    static let signOut = "rectangle.portrait.and.arrow.right"

    // MARK: Product categories

    static let categoryAll = "square.grid.2x2"
    static let categoryElectronics = "headphones"
    static let categoryFashion = "tshirt"
    static let categoryHome = "sofa"
    static let categoryBeauty = "sparkles"
    static let categorySports = "figure.run"

    // MARK: Payment

    static let paymentCash = "banknote"
    static let paymentQR = "qrcode"
    static let paymentCard = "creditcard"

    // MARK: Status

    static let star = "star.fill"
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

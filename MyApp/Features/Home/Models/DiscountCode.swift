import Foundation

/// A promo code shown in the Home "Discover discount codes" row.
///
/// These are local sample codes for the UI. Checkout does not apply codes yet; replace
/// `featured` with codes from the API once the backend supports them.
struct DiscountCode: Identifiable, Sendable {
    /// Visual theme of the coupon card.
    enum Style: Sendable {
        case crimson
        case sunset
        case lemon
        case blush
    }

    /// The code the customer enters at checkout, e.g. "GLOW30".
    let code: String
    /// Big headline on the card, e.g. "30% OFF".
    let headline: LocalizedStringResource
    /// One-line description of what the code applies to.
    let caption: LocalizedStringResource
    let style: Style

    var id: String { code }
}

extension DiscountCode {
    /// Codes featured on Home.
    static let featured: [DiscountCode] = [
        DiscountCode(code: "GLOW30", headline: "30% OFF", caption: "All skincare this week", style: .crimson),
        DiscountCode(code: "FLASH12", headline: "Flash Sale", caption: "12% off makeup today only", style: .sunset),
        DiscountCode(code: "FREESHIP", headline: "Free Ship", caption: "Free delivery on any order", style: .lemon),
        DiscountCode(code: "WELCOME10", headline: "10% OFF", caption: "Your first order", style: .blush)
    ]
}

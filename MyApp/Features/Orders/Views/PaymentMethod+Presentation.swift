import SwiftUI

extension PaymentMethod {
    /// Localized display name.
    var title: LocalizedStringKey {
        switch self {
        case .cashOnDelivery: "Cash on Delivery"
        case .khqr: "KHQR (Bank App)"
        case .card: "Credit / Debit Card"
        }
    }

    /// SF Symbol shown next to the name.
    var systemImage: String {
        switch self {
        case .cashOnDelivery: AppImages.paymentCash
        case .khqr: AppImages.paymentQR
        case .card: AppImages.paymentCard
        }
    }
}

import Foundation

/// How the customer pays for an order.
enum PaymentMethod: String, Codable, CaseIterable, Identifiable, Sendable {
    case cashOnDelivery
    /// Cambodia's national QR payment standard (scan with any bank app).
    case khqr
    case card

    var id: Self { self }
}

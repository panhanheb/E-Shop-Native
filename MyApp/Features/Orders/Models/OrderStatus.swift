import Foundation

/// Fulfilment stage of an order.
enum OrderStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case processing
    case shipped
    case delivered
    case cancelled
}

import Foundation

/// Where an order is delivered.
struct ShippingAddress: Codable, Equatable, Hashable, Sendable {
    var fullName: String
    var phone: String
    var street: String
    var city: String
}

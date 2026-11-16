import Foundation

extension JSONEncoder {
    /// An encoder configured for the API's conventions (ISO-8601 dates).
    static var api: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

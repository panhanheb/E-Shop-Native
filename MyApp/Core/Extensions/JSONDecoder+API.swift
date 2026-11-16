import Foundation

extension JSONDecoder {
    /// A decoder configured for the API's conventions (ISO-8601 dates).
    static var api: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

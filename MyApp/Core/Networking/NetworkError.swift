import Foundation

/// Errors produced by the networking layer.
enum NetworkError: Error, Equatable, Sendable {
    case invalidURL
    case invalidResponse
    case encodingFailed
    case decodingFailed
    case unauthorized
    case notFound
    case noConnection
    case server(statusCode: Int)
    case transport(message: String)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            String(localized: "The request URL is invalid.")
        case .invalidResponse:
            String(localized: "The server returned an invalid response.")
        case .encodingFailed:
            String(localized: "The request could not be prepared.")
        case .decodingFailed:
            String(localized: "The server response could not be read.")
        case .unauthorized:
            String(localized: "Your session has expired. Please sign in again.")
        case .notFound:
            String(localized: "The requested item could not be found.")
        case .noConnection:
            String(localized: "You appear to be offline. Check your connection and try again.")
        case .server(let statusCode):
            String(localized: "The server returned an error (\(statusCode)). Please try again later.")
        case .transport(let message):
            message
        }
    }
}

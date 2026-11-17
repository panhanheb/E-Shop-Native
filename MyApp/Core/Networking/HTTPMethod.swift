import Foundation

/// HTTP verbs supported by `APIClient`.
enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

import Foundation

/// Abstraction over the HTTP client so services can be tested with fakes.
protocol APIClientProtocol: Sendable {
    /// Sends the request and decodes the JSON response into `Response`.
    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint, as type: Response.Type) async throws -> Response

    /// Sends the request and ignores the response body.
    func send(_ endpoint: Endpoint) async throws
}

import Foundation

/// Describes a single REST request relative to the API base URL.
struct Endpoint: Sendable, Equatable {
    /// Path relative to the base URL, e.g. `"products/42"`.
    let path: String
    /// HTTP method of the request.
    let method: HTTPMethod
    /// Query string parameters.
    let queryItems: [URLQueryItem]
    /// Pre-encoded JSON body, if any.
    let body: Data?
    /// Whether the bearer token should be attached.
    let requiresAuthentication: Bool

    /// Creates an endpoint without a request body.
    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        requiresAuthentication: Bool = true
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = nil
        self.requiresAuthentication = requiresAuthentication
    }

    /// Creates an endpoint whose body is the JSON encoding of `body`.
    /// - Throws: `NetworkError.encodingFailed` if the body cannot be encoded.
    init<Body: Encodable>(
        path: String,
        method: HTTPMethod,
        body: Body,
        requiresAuthentication: Bool = true
    ) throws {
        self.path = path
        self.method = method
        self.queryItems = []
        self.requiresAuthentication = requiresAuthentication
        do {
            self.body = try JSONEncoder.api.encode(body)
        } catch {
            throw NetworkError.encodingFailed
        }
    }

    /// Builds a `URLRequest` for this endpoint against `baseURL`.
    func urlRequest(baseURL: URL) throws -> URLRequest {
        var components = URLComponents(
            url: baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        )
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}

import Foundation

/// `URLSession`-backed REST client that attaches the bearer token and maps errors.
final class APIClient: APIClientProtocol {
    private static let offlineCodes: Set<URLError.Code> = [
        .notConnectedToInternet,
        .networkConnectionLost,
        .timedOut,
        .cannotConnectToHost
    ]

    private let baseURL: URL
    private let session: URLSession
    private let tokenStore: any TokenStoreProtocol

    /// Creates a client.
    /// - Parameters:
    ///   - baseURL: Root URL of the API, e.g. `https://api.example.com/v1`.
    ///   - session: The session used to perform requests.
    ///   - tokenStore: Source of the bearer token for authenticated endpoints.
    init(baseURL: URL, session: URLSession = .shared, tokenStore: any TokenStoreProtocol) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStore = tokenStore
    }

    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint, as type: Response.Type) async throws -> Response {
        let data = try await data(for: endpoint)
        do {
            return try JSONDecoder.api.decode(Response.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func send(_ endpoint: Endpoint) async throws {
        _ = try await data(for: endpoint)
    }

    private func data(for endpoint: Endpoint) async throws -> Data {
        var request = try endpoint.urlRequest(baseURL: baseURL)
        if endpoint.requiresAuthentication, let token = await tokenStore.token() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as URLError where Self.offlineCodes.contains(error.code) {
            throw NetworkError.noConnection
        } catch {
            throw NetworkError.transport(message: error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return data
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        default:
            throw NetworkError.server(statusCode: httpResponse.statusCode)
        }
    }
}

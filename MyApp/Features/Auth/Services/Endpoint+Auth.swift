import Foundation

extension Endpoint {
    /// `POST /auth/login`
    static func login(_ request: LoginRequest) throws -> Endpoint {
        try Endpoint(path: "auth/login", method: .post, body: request, requiresAuthentication: false)
    }

    /// `POST /auth/register`
    static func register(_ request: RegisterRequest) throws -> Endpoint {
        try Endpoint(path: "auth/register", method: .post, body: request, requiresAuthentication: false)
    }

    /// `POST /auth/logout`
    static let logout = Endpoint(path: "auth/logout", method: .post)
}

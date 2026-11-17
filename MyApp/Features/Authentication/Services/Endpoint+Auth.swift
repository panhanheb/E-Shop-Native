import Foundation

extension Endpoint {
    /// `POST /auth/login`
    static func login(_ request: LoginRequest) throws -> Endpoint {
        try Endpoint(path: AppEndPoint.login, method: .post, body: request, requiresAuthentication: false)
    }

    /// `POST /auth/register`
    static func register(_ request: RegisterRequest) throws -> Endpoint {
        try Endpoint(path: AppEndPoint.register, method: .post, body: request, requiresAuthentication: false)
    }

    /// `POST /auth/logout`
    static let logout = Endpoint(path: AppEndPoint.logout, method: .post)
}

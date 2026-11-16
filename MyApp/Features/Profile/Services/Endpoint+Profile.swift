import Foundation

extension Endpoint {
    /// `GET /me`
    static let profile = Endpoint(path: AppEndPoint.profile)

    /// `PATCH /me`
    static func updateProfile(_ request: UpdateProfileRequest) throws -> Endpoint {
        try Endpoint(path: AppEndPoint.profile, method: .patch, body: request)
    }
}

import Foundation

extension Endpoint {
    /// `GET /me`
    static let profile = Endpoint(path: "me")

    /// `PATCH /me`
    static func updateProfile(_ request: UpdateProfileRequest) throws -> Endpoint {
        try Endpoint(path: "me", method: .patch, body: request)
    }
}

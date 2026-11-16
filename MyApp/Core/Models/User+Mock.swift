import Foundation

extension User {
    /// Sample user for previews, mock services, and tests.
    static let mock = User(
        id: UUID(),
        name: "Alex Morgan",
        email: "demo@example.com",
        avatarURL: nil,
        joinedAt: Date(timeIntervalSince1970: 1_704_067_200)
    )
}

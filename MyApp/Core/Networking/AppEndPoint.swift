import Foundation

/// Every REST path the app calls, relative to `AppEnvironment.baseURL`.
///
/// Endpoints are built from these in the `Endpoint+<Feature>.swift` files.
enum AppEndPoint {
    // MARK: Auth

    static let login = "auth/login"
    static let register = "auth/register"
    static let logout = "auth/logout"

    // MARK: Profile

    static let profile = "me"

    // MARK: Tasks

    static let tasks = "tasks"

    /// `tasks/{id}`
    static func task(id: UUID) -> String {
        "\(tasks)/\(id.uuidString)"
    }
}

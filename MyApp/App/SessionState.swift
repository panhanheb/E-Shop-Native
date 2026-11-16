import Foundation

/// Authentication state of the app.
enum SessionState: Equatable, Sendable {
    /// Checking for a stored session at launch.
    case restoring
    /// No signed-in user.
    case signedOut
    /// A user is signed in.
    case signedIn(User)
}

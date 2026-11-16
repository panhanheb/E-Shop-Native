import Foundation

/// In-memory user store shared by the mock auth and profile services.
///
/// Stands in for the backend until the REST API is available.
actor MockUserDatabase {
    /// Email of the seeded demo account.
    static let demoEmail = "demo@example.com"
    /// Password of the seeded demo account.
    static let demoPassword = "password123"

    private struct Account: Sendable {
        var user: User
        let password: String
    }

    private var accounts: [String: Account] = [:]
    private var currentUserKey: String?

    /// Creates the database with the demo account, optionally already signed in as `signedInUser`.
    init(signedInUser: User? = nil) {
        let demo = User.mock
        accounts[demo.email.lowercased()] = Account(user: demo, password: Self.demoPassword)

        if let signedInUser {
            let key = signedInUser.email.lowercased()
            accounts[key] = Account(user: signedInUser, password: Self.demoPassword)
            currentUserKey = key
        }
    }

    /// Returns the user matching the credentials and marks them as signed in.
    func authenticate(email: String, password: String) -> User? {
        let key = email.lowercased()
        guard let account = accounts[key], account.password == password else {
            return nil
        }
        currentUserKey = key
        return account.user
    }

    /// Creates and signs in a new account, or returns `nil` if the email is taken.
    func createAccount(name: String, email: String, password: String) -> User? {
        let key = email.lowercased()
        guard accounts[key] == nil else {
            return nil
        }
        let user = User(id: UUID(), name: name, email: email, avatarURL: nil, joinedAt: .now)
        accounts[key] = Account(user: user, password: password)
        currentUserKey = key
        return user
    }

    /// The currently signed-in user, if any.
    func currentUser() -> User? {
        currentUserKey.flatMap { accounts[$0]?.user }
    }

    /// Renames the signed-in user and returns the updated value.
    func updateCurrentUser(name: String) -> User? {
        guard let key = currentUserKey, var account = accounts[key] else {
            return nil
        }
        account.user.name = name
        accounts[key] = account
        return account.user
    }

    /// Ends the current session.
    func signOut() {
        currentUserKey = nil
    }
}

import Testing
@testable import MyApp

@MainActor
struct SessionStoreTests {
    private let authService = StubAuthService()
    private let profileService = StubProfileService()

    private func makeSUT(tokenStore: InMemoryTokenStore) -> SessionStore {
        SessionStore(tokenStore: tokenStore, authService: authService, profileService: profileService)
    }

    @Test func restoreWithoutTokenSignsOut() async {
        let sut = makeSUT(tokenStore: InMemoryTokenStore())

        await sut.restore()

        #expect(sut.state == .signedOut)
        #expect(profileService.fetchCallCount == 0)
    }

    @Test func restoreWithTokenSignsIn() async {
        let sut = makeSUT(tokenStore: InMemoryTokenStore(token: "valid"))

        await sut.restore()

        #expect(sut.state == .signedIn(.mock))
        #expect(sut.currentUser == .mock)
    }

    @Test func restoreWithExpiredTokenClearsIt() async {
        let tokenStore = InMemoryTokenStore(token: "expired")
        profileService.fetchError = NetworkError.unauthorized
        let sut = makeSUT(tokenStore: tokenStore)

        await sut.restore()

        let token = await tokenStore.token()
        #expect(sut.state == .signedOut)
        #expect(token == nil)
    }

    @Test func restoreWhileOfflineKeepsToken() async {
        let tokenStore = InMemoryTokenStore(token: "valid")
        profileService.fetchError = NetworkError.noConnection
        let sut = makeSUT(tokenStore: tokenStore)

        await sut.restore()

        let token = await tokenStore.token()
        #expect(sut.state == .signedOut)
        #expect(token == "valid")
    }

    @Test func signInStoresTokenAndUser() async throws {
        let tokenStore = InMemoryTokenStore()
        let sut = makeSUT(tokenStore: tokenStore)

        try await sut.signIn(with: AuthResponse(token: "new-token", user: .mock))

        let token = await tokenStore.token()
        #expect(token == "new-token")
        #expect(sut.state == .signedIn(.mock))
    }

    @Test func updateUserReplacesCachedUser() async throws {
        let sut = makeSUT(tokenStore: InMemoryTokenStore())
        try await sut.signIn(with: AuthResponse(token: "token", user: .mock))
        var renamed = User.mock
        renamed.name = "Renamed"

        sut.updateUser(renamed)

        #expect(sut.currentUser?.name == "Renamed")
    }

    @Test func signOutClearsTokenEvenIfServerFails() async throws {
        let tokenStore = InMemoryTokenStore()
        authService.logoutError = TestError.stub
        let sut = makeSUT(tokenStore: tokenStore)
        try await sut.signIn(with: AuthResponse(token: "token", user: .mock))

        await sut.signOut()

        let token = await tokenStore.token()
        #expect(sut.state == .signedOut)
        #expect(token == nil)
        #expect(authService.logoutCallCount == 1)
    }
}

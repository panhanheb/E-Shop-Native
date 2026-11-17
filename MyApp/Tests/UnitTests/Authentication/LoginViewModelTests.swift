import Testing
@testable import MyApp

@MainActor
struct LoginViewModelTests {
    @Test func canSubmitRequiresValidEmailAndPassword() {
        let sut = LoginViewModel(authService: StubAuthService()) { _ in }
        #expect(!sut.canSubmit)

        sut.email = "not-an-email"
        sut.password = "password123"
        #expect(!sut.canSubmit)

        sut.email = "user@example.com"
        sut.password = ""
        #expect(!sut.canSubmit)

        sut.password = "password123"
        #expect(sut.canSubmit)
    }

    @Test func successfulLoginSendsTrimmedEmailAndForwardsResponse() async {
        let service = StubAuthService()
        let recorder = CallRecorder<AuthResponse>()
        let sut = LoginViewModel(authService: service) { recorder.record($0) }
        sut.email = "  user@example.com "
        sut.password = "password123"

        await sut.login()

        #expect(service.loginRequests == [LoginRequest(email: "user@example.com", password: "password123")])
        #expect(recorder.last?.token == "token")
        #expect(sut.errorMessage == nil)
        #expect(!sut.isLoading)
    }

    @Test func failedLoginShowsErrorAndDoesNotAuthenticate() async {
        let service = StubAuthService()
        service.loginResult = .failure(AuthError.invalidCredentials)
        let recorder = CallRecorder<AuthResponse>()
        let sut = LoginViewModel(authService: service) { recorder.record($0) }
        sut.email = "user@example.com"
        sut.password = "wrong"

        await sut.login()

        #expect(sut.errorMessage == AuthError.invalidCredentials.localizedDescription)
        #expect(recorder.count == 0)
        #expect(!sut.isLoading)
    }

    @Test func failureInAuthenticationHandlerIsShown() async {
        let sut = LoginViewModel(authService: StubAuthService()) { _ in throw TestError.stub }
        sut.email = "user@example.com"
        sut.password = "password123"

        await sut.login()

        #expect(sut.errorMessage == TestError.stub.localizedDescription)
    }

    @Test func invalidFormDoesNotCallService() async {
        let service = StubAuthService()
        let sut = LoginViewModel(authService: service) { _ in }

        await sut.login()

        #expect(service.loginRequests.isEmpty)
    }
}

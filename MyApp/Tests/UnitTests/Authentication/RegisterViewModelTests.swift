import Testing
@testable import MyApp

@MainActor
struct RegisterViewModelTests {
    private func makeFilledViewModel(service: StubAuthService, recorder: CallRecorder<AuthResponse>) -> RegisterViewModel {
        let sut = RegisterViewModel(authService: service) { recorder.record($0) }
        sut.name = " Jamie Lee "
        sut.email = "jamie@example.com"
        sut.password = "supersecret"
        sut.confirmPassword = "supersecret"
        return sut
    }

    @Test func validFormCanSubmit() {
        let sut = makeFilledViewModel(service: StubAuthService(), recorder: CallRecorder())
        #expect(sut.canSubmit)
        #expect(sut.validationMessage == nil)
    }

    @Test func mismatchedPasswordsBlockSubmission() {
        let sut = makeFilledViewModel(service: StubAuthService(), recorder: CallRecorder())
        sut.confirmPassword = "different"

        #expect(!sut.canSubmit)
        #expect(sut.validationMessage != nil)
    }

    @Test func shortPasswordBlocksSubmission() {
        let sut = makeFilledViewModel(service: StubAuthService(), recorder: CallRecorder())
        sut.password = "short"
        sut.confirmPassword = "short"

        #expect(!sut.canSubmit)
        #expect(sut.validationMessage != nil)
    }

    @Test func successfulRegistrationSendsTrimmedValues() async {
        let service = StubAuthService()
        let recorder = CallRecorder<AuthResponse>()
        let sut = makeFilledViewModel(service: service, recorder: recorder)

        await sut.register()

        #expect(service.registerRequests == [
            RegisterRequest(name: "Jamie Lee", email: "jamie@example.com", password: "supersecret")
        ])
        #expect(recorder.count == 1)
        #expect(sut.errorMessage == nil)
    }

    @Test func emailInUseShowsError() async {
        let service = StubAuthService()
        service.registerResult = .failure(AuthError.emailAlreadyInUse)
        let recorder = CallRecorder<AuthResponse>()
        let sut = makeFilledViewModel(service: service, recorder: recorder)

        await sut.register()

        #expect(sut.errorMessage == AuthError.emailAlreadyInUse.localizedDescription)
        #expect(recorder.count == 0)
        #expect(!sut.isLoading)
    }
}

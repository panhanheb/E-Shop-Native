import Testing
@testable import MyApp

@MainActor
struct ProfileViewModelTests {
    private let service = StubProfileService()
    private let updates = CallRecorder<User>()
    private let signOuts = CallRecorder<Void>()

    private func makeSUT(user: User? = .mock) -> ProfileViewModel {
        ProfileViewModel(
            user: user,
            profileService: service,
            onProfileUpdated: { [updates] in updates.record($0) },
            onSignOut: { [signOuts] in signOuts.record(()) }
        )
    }

    @Test func loadProfileUpdatesUserAndNotifies() async {
        let sut = makeSUT(user: nil)

        await sut.loadProfile()

        #expect(sut.user == .mock)
        #expect(updates.last == .mock)
        #expect(sut.hasLoaded)
        #expect(!sut.isLoading)
    }

    @Test func loadFailureSetsError() async {
        service.fetchError = TestError.stub
        let sut = makeSUT(user: nil)

        await sut.loadProfile()

        #expect(sut.user == nil)
        #expect(sut.errorMessage == TestError.stub.localizedDescription)
        #expect(sut.hasLoaded)
    }

    @Test func beginEditingSeedsDraft() {
        let sut = makeSUT()

        sut.beginEditing()

        #expect(sut.isEditing)
        #expect(sut.draftName == User.mock.name)
        #expect(!sut.canSaveProfile)
    }

    @Test func saveProfileUpdatesUserAndClosesEditor() async {
        let sut = makeSUT()
        sut.beginEditing()
        sut.draftName = "  Taylor Swift-Kim "

        await sut.saveProfile()

        #expect(service.updateRequests == [UpdateProfileRequest(name: "Taylor Swift-Kim")])
        #expect(sut.user?.name == "Taylor Swift-Kim")
        #expect(updates.last?.name == "Taylor Swift-Kim")
        #expect(!sut.isEditing)
    }

    @Test func saveFailureKeepsEditorOpen() async {
        service.updateError = TestError.stub
        let sut = makeSUT()
        sut.beginEditing()
        sut.draftName = "New Name"

        await sut.saveProfile()

        #expect(sut.isEditing)
        #expect(sut.user == .mock)
        #expect(sut.errorMessage != nil)
    }

    @Test func signOutInvokesHandler() async {
        let sut = makeSUT()

        await sut.signOut()

        #expect(signOuts.count == 1)
        #expect(!sut.isSigningOut)
    }
}

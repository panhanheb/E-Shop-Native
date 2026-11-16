import Testing
@testable import MyApp

@MainActor
struct SettingsViewModelTests {
    private let service = StubSettingsService()

    private func makeSUT() -> SettingsViewModel {
        SettingsViewModel(settingsService: service, appVersion: "1.0 (1)")
    }

    @Test func loadAppliesStoredSettings() async {
        service.storedSettings = AppSettings(appearance: .dark, notificationsEnabled: false, hapticsEnabled: true)
        let sut = makeSUT()

        await sut.load()

        #expect(sut.settings == service.storedSettings)
        #expect(sut.hasLoaded)
        #expect(!sut.isLoading)
    }

    @Test func loadFailureFallsBackToDefaults() async {
        service.loadError = TestError.stub
        let sut = makeSUT()

        await sut.load()

        #expect(sut.settings == .default)
        #expect(sut.errorMessage == TestError.stub.localizedDescription)
    }

    @Test func changingAppearancePersists() async {
        let sut = makeSUT()
        await sut.load()

        sut.appearance = .dark
        await sut.waitForPendingSave()

        #expect(sut.appearance == .dark)
        #expect(service.storedSettings.appearance == .dark)
    }

    @Test func togglesPersist() async {
        let sut = makeSUT()
        await sut.load()

        sut.notificationsEnabled = false
        await sut.waitForPendingSave()
        sut.hapticsEnabled = false
        await sut.waitForPendingSave()

        #expect(service.storedSettings.notificationsEnabled == false)
        #expect(service.storedSettings.hapticsEnabled == false)
        #expect(service.saveCallCount == 2)
    }

    @Test func settingSameValueDoesNotSave() async {
        let sut = makeSUT()
        await sut.load()

        sut.appearance = AppSettings.default.appearance
        await sut.waitForPendingSave()

        #expect(service.saveCallCount == 0)
    }

    @Test func saveFailureRevertsChange() async {
        service.saveError = TestError.stub
        let sut = makeSUT()
        await sut.load()

        sut.appearance = .light
        await sut.waitForPendingSave()

        #expect(sut.appearance == AppSettings.default.appearance)
        #expect(sut.errorMessage == TestError.stub.localizedDescription)
    }
}

import Foundation
import Observation

/// Composition root: builds services once and creates view models with their dependencies.
@Observable
@MainActor
final class AppDependencies {
    let authService: any AuthServiceProtocol
    let taskService: any TaskServiceProtocol
    let profileService: any ProfileServiceProtocol
    let sessionStore: SessionStore
    /// Shared so the root view can apply the selected appearance.
    let settingsViewModel: SettingsViewModel
    /// Whether the in-memory mock backend is in use.
    let isUsingMockServices: Bool

    /// Creates the container from concrete services.
    init(
        authService: any AuthServiceProtocol,
        taskService: any TaskServiceProtocol,
        profileService: any ProfileServiceProtocol,
        settingsService: any SettingsServiceProtocol,
        tokenStore: any TokenStoreProtocol,
        isUsingMockServices: Bool,
        appVersion: String = Bundle.main.appVersion
    ) {
        self.authService = authService
        self.taskService = taskService
        self.profileService = profileService
        self.isUsingMockServices = isUsingMockServices
        self.sessionStore = SessionStore(
            tokenStore: tokenStore,
            authService: authService,
            profileService: profileService
        )
        self.settingsViewModel = SettingsViewModel(settingsService: settingsService, appVersion: appVersion)
    }

    // MARK: - Factories

    /// Builds the container for `environment`.
    static func make(for environment: AppEnvironment) -> AppDependencies {
        environment.useMockServices
            ? mock(latency: environment.mockLatency)
            : live(baseURL: environment.baseURL)
    }

    /// Container backed by the REST API and Keychain.
    static func live(baseURL: URL) -> AppDependencies {
        let tokenStore = KeychainTokenStore()
        let apiClient = APIClient(baseURL: baseURL, tokenStore: tokenStore)
        return AppDependencies(
            authService: AuthService(apiClient: apiClient),
            taskService: TaskService(apiClient: apiClient),
            profileService: ProfileService(apiClient: apiClient),
            settingsService: SettingsService(),
            tokenStore: tokenStore,
            isUsingMockServices: false
        )
    }

    /// Container backed by in-memory mock services.
    static func mock(
        latency: Duration = .milliseconds(600),
        signedInUser: User? = nil,
        settingsService: (any SettingsServiceProtocol)? = nil
    ) -> AppDependencies {
        let database = MockUserDatabase(signedInUser: signedInUser)
        return AppDependencies(
            authService: MockAuthService(database: database, latency: latency),
            taskService: MockTaskService(latency: latency),
            profileService: MockProfileService(database: database, latency: latency),
            settingsService: settingsService ?? SettingsService(),
            tokenStore: InMemoryTokenStore(token: signedInUser == nil ? nil : "preview-token"),
            isUsingMockServices: true
        )
    }

    /// Instant, signed-in mock container for SwiftUI previews.
    static var preview: AppDependencies {
        mock(latency: .zero, signedInUser: .mock, settingsService: MockSettingsService())
    }

    // MARK: - View model factories

    /// Creates the login screen's view model.
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authService: authService) { [sessionStore] response in
            try await sessionStore.signIn(with: response)
        }
    }

    /// Creates the registration screen's view model.
    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(authService: authService) { [sessionStore] response in
            try await sessionStore.signIn(with: response)
        }
    }

    /// Creates the task list's view model.
    func makeTaskListViewModel() -> TaskListViewModel {
        TaskListViewModel(taskService: taskService)
    }

    /// Creates a task detail view model.
    func makeTaskDetailViewModel(
        task: TaskItem,
        onUpdate: @escaping @MainActor (TaskItem) -> Void,
        onDelete: @escaping @MainActor (TaskItem) -> Void
    ) -> TaskDetailViewModel {
        TaskDetailViewModel(task: task, taskService: taskService, onUpdate: onUpdate, onDelete: onDelete)
    }

    /// Creates the add-task form's view model.
    func makeAddTaskViewModel(onCreate: @escaping @MainActor (TaskItem) -> Void) -> AddTaskViewModel {
        AddTaskViewModel(taskService: taskService, onCreate: onCreate)
    }

    /// Creates the profile screen's view model.
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            user: sessionStore.currentUser,
            profileService: profileService,
            onProfileUpdated: { [sessionStore] user in sessionStore.updateUser(user) },
            onSignOut: { [sessionStore] in await sessionStore.signOut() }
        )
    }
}

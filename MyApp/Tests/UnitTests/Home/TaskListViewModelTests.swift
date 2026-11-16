import Testing
@testable import MyApp

@MainActor
struct TaskListViewModelTests {
    @Test func loadTasksPopulatesList() async {
        let sut = TaskListViewModel(taskService: StubTaskService())

        await sut.loadTasks()

        #expect(sut.tasks == TaskItem.mocks)
        #expect(sut.hasLoaded)
        #expect(sut.errorMessage == nil)
        #expect(!sut.isLoading)
    }

    @Test func loadFailureSetsErrorWithoutAlert() async {
        let service = StubTaskService()
        service.fetchError = TestError.stub
        let sut = TaskListViewModel(taskService: service)

        await sut.loadTasks()

        #expect(sut.tasks.isEmpty)
        #expect(!sut.hasLoaded)
        #expect(sut.errorMessage == TestError.stub.localizedDescription)
        #expect(!sut.isErrorAlertPresented)
    }

    @Test func loadIfNeededOnlyLoadsOnce() async {
        let service = StubTaskService()
        let sut = TaskListViewModel(taskService: service)
        await sut.loadIfNeeded()

        service.tasks = []
        await sut.loadIfNeeded()

        #expect(sut.tasks == TaskItem.mocks)
    }

    @Test(arguments: TaskFilter.allCases)
    func filterRestrictsVisibleTasks(_ filter: TaskFilter) async {
        let sut = TaskListViewModel(taskService: StubTaskService())
        await sut.loadTasks()

        sut.filter = filter

        let expected = switch filter {
        case .all: TaskItem.mocks
        case .active: TaskItem.mocks.filter { !$0.isCompleted }
        case .completed: TaskItem.mocks.filter(\.isCompleted)
        }
        #expect(sut.visibleTasks == expected)
    }

    @Test func searchMatchesTitleCaseInsensitively() async {
        let sut = TaskListViewModel(taskService: StubTaskService())
        await sut.loadTasks()

        sut.searchText = "  GROCERIES "

        #expect(sut.visibleTasks.map(\.title) == ["Buy groceries"])
    }

    @Test func toggleCompletionPersistsChange() async throws {
        let service = StubTaskService()
        let sut = TaskListViewModel(taskService: service)
        await sut.loadTasks()
        let task = try #require(sut.tasks.first)

        await sut.toggleCompletion(of: task)

        #expect(sut.tasks.first?.isCompleted == !task.isCompleted)
        #expect(service.updatedTasks.count == 1)
    }

    @Test func toggleCompletionRevertsOnFailure() async throws {
        let service = StubTaskService()
        let sut = TaskListViewModel(taskService: service)
        await sut.loadTasks()
        let task = try #require(sut.tasks.first)
        service.mutationError = TestError.stub

        await sut.toggleCompletion(of: task)

        #expect(sut.tasks.first?.isCompleted == task.isCompleted)
        #expect(sut.isErrorAlertPresented)
    }

    @Test func deleteRemovesTask() async throws {
        let service = StubTaskService()
        let sut = TaskListViewModel(taskService: service)
        await sut.loadTasks()
        let task = try #require(sut.tasks.first)

        await sut.delete(task)

        #expect(!sut.tasks.contains(task))
        #expect(service.deletedIDs == [task.id])
    }

    @Test func deleteRestoresTaskOnFailure() async throws {
        let service = StubTaskService()
        let sut = TaskListViewModel(taskService: service)
        await sut.loadTasks()
        let task = try #require(sut.tasks.first)
        service.mutationError = TestError.stub

        await sut.delete(task)

        #expect(sut.tasks == TaskItem.mocks)
        #expect(sut.errorMessage != nil)
    }

    @Test func dismissingAlertClearsError() async throws {
        let service = StubTaskService()
        let sut = TaskListViewModel(taskService: service)
        await sut.loadTasks()
        service.mutationError = TestError.stub
        await sut.delete(try #require(sut.tasks.first))

        sut.isErrorAlertPresented = false

        #expect(sut.errorMessage == nil)
    }

    @Test func externalChangesAreApplied() async throws {
        let sut = TaskListViewModel(taskService: StubTaskService(tasks: []))
        await sut.loadTasks()
        var task = TaskItem.mock

        sut.didCreate(task)
        #expect(sut.tasks == [task])

        task.title = "Renamed"
        sut.didUpdate(task)
        #expect(sut.tasks.first?.title == "Renamed")

        sut.didDelete(task)
        #expect(sut.tasks.isEmpty)
    }
}

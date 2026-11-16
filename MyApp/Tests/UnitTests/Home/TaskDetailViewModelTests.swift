import Testing
@testable import MyApp

@MainActor
struct TaskDetailViewModelTests {
    @Test func refreshPicksUpServerChanges() async {
        var serverTask = TaskItem.mock
        serverTask.title = "Updated on server"
        let service = StubTaskService(tasks: [serverTask])
        let updates = CallRecorder<TaskItem>()
        let sut = TaskDetailViewModel(task: .mock, taskService: service, onUpdate: { updates.record($0) })

        await sut.refresh()

        #expect(sut.task.title == "Updated on server")
        #expect(updates.last == serverTask)
        #expect(!sut.isLoading)
    }

    @Test func refreshFailureKeepsCurrentTask() async {
        let service = StubTaskService()
        service.fetchError = TestError.stub
        let sut = TaskDetailViewModel(task: .mock, taskService: service)

        await sut.refresh()

        #expect(sut.task == .mock)
        #expect(sut.errorMessage == TestError.stub.localizedDescription)
    }

    @Test func toggleCompletionUpdatesTaskAndNotifies() async {
        let updates = CallRecorder<TaskItem>()
        let sut = TaskDetailViewModel(task: .mock, taskService: StubTaskService(), onUpdate: { updates.record($0) })

        await sut.toggleCompletion()

        #expect(sut.task.isCompleted == !TaskItem.mock.isCompleted)
        #expect(updates.count == 1)
        #expect(!sut.isSaving)
    }

    @Test func toggleCompletionFailureKeepsState() async {
        let service = StubTaskService()
        service.mutationError = TestError.stub
        let sut = TaskDetailViewModel(task: .mock, taskService: service)

        await sut.toggleCompletion()

        #expect(sut.task == .mock)
        #expect(sut.errorMessage != nil)
    }

    @Test func deleteMarksDeletedAndNotifies() async {
        let deletions = CallRecorder<TaskItem>()
        let service = StubTaskService()
        let sut = TaskDetailViewModel(task: .mock, taskService: service, onDelete: { deletions.record($0) })

        await sut.delete()

        #expect(sut.isDeleted)
        #expect(deletions.last == .mock)
        #expect(service.deletedIDs == [TaskItem.mock.id])
    }

    @Test func deleteFailureDoesNotDismiss() async {
        let service = StubTaskService()
        service.mutationError = TestError.stub
        let sut = TaskDetailViewModel(task: .mock, taskService: service)

        await sut.delete()

        #expect(!sut.isDeleted)
        #expect(sut.errorMessage != nil)
    }
}

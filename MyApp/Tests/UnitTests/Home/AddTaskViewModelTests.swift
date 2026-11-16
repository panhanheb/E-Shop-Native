import Testing
@testable import MyApp

@MainActor
struct AddTaskViewModelTests {
    @Test func cannotSaveWithBlankTitle() {
        let sut = AddTaskViewModel(taskService: StubTaskService()) { _ in }
        #expect(!sut.canSave)

        sut.title = "   "
        #expect(!sut.canSave)

        sut.title = "Write tests"
        #expect(sut.canSave)
    }

    @Test func saveCreatesTrimmedDraftWithoutDueDate() async {
        let service = StubTaskService(tasks: [])
        let created = CallRecorder<TaskItem>()
        let sut = AddTaskViewModel(taskService: service) { created.record($0) }
        sut.title = "  Write tests "
        sut.notes = " Cover failure paths "
        sut.priority = .high
        sut.hasDueDate = false

        await sut.save()

        #expect(service.createdDrafts == [
            TaskDraft(title: "Write tests", notes: "Cover failure paths", dueDate: nil, priority: .high)
        ])
        #expect(created.count == 1)
        #expect(sut.didSave)
        #expect(!sut.isSaving)
    }

    @Test func saveIncludesDueDateWhenEnabled() async {
        let service = StubTaskService(tasks: [])
        let sut = AddTaskViewModel(taskService: service) { _ in }
        sut.title = "Ship release"
        sut.hasDueDate = true

        await sut.save()

        #expect(service.createdDrafts.first?.dueDate == sut.dueDate)
    }

    @Test func saveFailureShowsErrorAndStaysOpen() async {
        let service = StubTaskService()
        service.mutationError = TestError.stub
        let created = CallRecorder<TaskItem>()
        let sut = AddTaskViewModel(taskService: service) { created.record($0) }
        sut.title = "Write tests"

        await sut.save()

        #expect(!sut.didSave)
        #expect(created.count == 0)
        #expect(sut.errorMessage == TestError.stub.localizedDescription)
    }
}

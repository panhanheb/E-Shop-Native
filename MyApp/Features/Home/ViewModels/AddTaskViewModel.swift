import Foundation
import Observation

/// Form state and submission for creating a task.
@Observable
@MainActor
final class AddTaskViewModel {
    var title = ""
    var notes = ""
    var priority: TaskPriority = .medium
    var hasDueDate = false
    var dueDate = Date.now.addingTimeInterval(86_400)
    private(set) var isSaving = false
    private(set) var didSave = false
    var errorMessage: String?

    private let taskService: any TaskServiceProtocol
    private let onCreate: @MainActor (TaskItem) -> Void

    /// Creates the view model.
    /// - Parameters:
    ///   - taskService: Service used to create the task.
    ///   - onCreate: Called with the stored task after a successful save.
    init(taskService: any TaskServiceProtocol, onCreate: @escaping @MainActor (TaskItem) -> Void) {
        self.taskService = taskService
        self.onCreate = onCreate
    }

    /// Whether the form is valid and not already saving.
    var canSave: Bool {
        !title.trimmed.isEmpty && !isSaving
    }

    /// Creates the task. Sets `didSave` on success so the view can dismiss.
    func save() async {
        guard canSave else { return }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let draft = TaskDraft(
            title: title.trimmed,
            notes: notes.trimmed,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority
        )

        do {
            let task = try await taskService.createTask(draft)
            onCreate(task)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

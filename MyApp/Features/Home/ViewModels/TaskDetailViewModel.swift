import Foundation
import Observation

/// State and actions for a single task's detail screen.
@Observable
@MainActor
final class TaskDetailViewModel {
    private(set) var task: TaskItem
    private(set) var isLoading = false
    private(set) var isSaving = false
    private(set) var isDeleted = false
    var errorMessage: String?

    private let taskService: any TaskServiceProtocol
    private let onUpdate: @MainActor (TaskItem) -> Void
    private let onDelete: @MainActor (TaskItem) -> Void

    /// Creates the view model.
    /// - Parameters:
    ///   - task: The task to display (shown immediately, then refreshed).
    ///   - taskService: Service used to fetch and mutate the task.
    ///   - onUpdate: Called after the task changes.
    ///   - onDelete: Called after the task is deleted.
    init(
        task: TaskItem,
        taskService: any TaskServiceProtocol,
        onUpdate: @escaping @MainActor (TaskItem) -> Void = { _ in },
        onDelete: @escaping @MainActor (TaskItem) -> Void = { _ in }
    ) {
        self.task = task
        self.taskService = taskService
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }

    /// Re-fetches the latest version of the task.
    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let latest = try await taskService.fetchTask(id: task.id)
            if latest != task {
                task = latest
                onUpdate(latest)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Marks the task complete or incomplete.
    func toggleCompletion() async {
        guard !isSaving else { return }

        var updated = task
        updated.isCompleted.toggle()

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            task = try await taskService.updateTask(updated)
            onUpdate(task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Deletes the task. Sets `isDeleted` on success so the view can dismiss.
    func delete() async {
        guard !isSaving else { return }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await taskService.deleteTask(id: task.id)
            onDelete(task)
            isDeleted = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

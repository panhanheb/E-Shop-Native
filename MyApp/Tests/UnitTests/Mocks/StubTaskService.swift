import Foundation
@testable import MyApp

/// Configurable `TaskServiceProtocol` that records calls.
@MainActor
final class StubTaskService: TaskServiceProtocol {
    var tasks: [TaskItem]
    var fetchError: (any Error)?
    var mutationError: (any Error)?

    private(set) var createdDrafts: [TaskDraft] = []
    private(set) var updatedTasks: [TaskItem] = []
    private(set) var deletedIDs: [TaskItem.ID] = []

    init(tasks: [TaskItem] = TaskItem.mocks) {
        self.tasks = tasks
    }

    func fetchTasks() async throws -> [TaskItem] {
        if let fetchError { throw fetchError }
        return tasks
    }

    func fetchTask(id: TaskItem.ID) async throws -> TaskItem {
        if let fetchError { throw fetchError }
        guard let task = tasks.first(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        return task
    }

    func createTask(_ draft: TaskDraft) async throws -> TaskItem {
        createdDrafts.append(draft)
        if let mutationError { throw mutationError }
        let task = TaskItem(
            id: UUID(),
            title: draft.title,
            notes: draft.notes,
            dueDate: draft.dueDate,
            priority: draft.priority,
            isCompleted: false,
            createdAt: .now
        )
        tasks.insert(task, at: 0)
        return task
    }

    func updateTask(_ task: TaskItem) async throws -> TaskItem {
        updatedTasks.append(task)
        if let mutationError { throw mutationError }
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
        return task
    }

    func deleteTask(id: TaskItem.ID) async throws {
        deletedIDs.append(id)
        if let mutationError { throw mutationError }
        tasks.removeAll { $0.id == id }
    }
}

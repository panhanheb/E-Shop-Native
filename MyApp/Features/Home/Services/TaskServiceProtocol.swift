import Foundation

/// CRUD operations for the user's tasks.
protocol TaskServiceProtocol: Sendable {
    /// Returns all tasks for the signed-in user.
    func fetchTasks() async throws -> [TaskItem]

    /// Returns a single task.
    func fetchTask(id: TaskItem.ID) async throws -> TaskItem

    /// Creates a task from `draft` and returns the stored value.
    func createTask(_ draft: TaskDraft) async throws -> TaskItem

    /// Replaces a task and returns the stored value.
    func updateTask(_ task: TaskItem) async throws -> TaskItem

    /// Deletes a task.
    func deleteTask(id: TaskItem.ID) async throws
}

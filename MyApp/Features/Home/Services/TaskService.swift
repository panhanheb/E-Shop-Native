import Foundation

/// REST implementation of `TaskServiceProtocol`.
final class TaskService: TaskServiceProtocol {
    private let apiClient: any APIClientProtocol

    /// Creates the service backed by `apiClient`.
    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchTasks() async throws -> [TaskItem] {
        try await apiClient.send(.tasks, as: [TaskItem].self)
    }

    func fetchTask(id: TaskItem.ID) async throws -> TaskItem {
        try await apiClient.send(.task(id: id), as: TaskItem.self)
    }

    func createTask(_ draft: TaskDraft) async throws -> TaskItem {
        try await apiClient.send(Endpoint.createTask(draft), as: TaskItem.self)
    }

    func updateTask(_ task: TaskItem) async throws -> TaskItem {
        try await apiClient.send(Endpoint.updateTask(task), as: TaskItem.self)
    }

    func deleteTask(id: TaskItem.ID) async throws {
        try await apiClient.send(.deleteTask(id: id))
    }
}

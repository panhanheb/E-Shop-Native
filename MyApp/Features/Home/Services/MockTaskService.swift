import Foundation

/// In-memory `TaskServiceProtocol` used until the backend is available, and in previews.
actor MockTaskService: TaskServiceProtocol {
    private var tasks: [TaskItem]
    private let latency: Duration

    /// Creates the mock.
    /// - Parameters:
    ///   - tasks: Initial tasks.
    ///   - latency: Simulated network delay.
    init(tasks: [TaskItem] = TaskItem.mocks, latency: Duration = .milliseconds(600)) {
        self.tasks = tasks
        self.latency = latency
    }

    func fetchTasks() async throws -> [TaskItem] {
        try await Task.sleep(for: latency)
        return tasks.sorted { $0.createdAt > $1.createdAt }
    }

    func fetchTask(id: TaskItem.ID) async throws -> TaskItem {
        try await Task.sleep(for: latency)
        guard let task = tasks.first(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        return task
    }

    func createTask(_ draft: TaskDraft) async throws -> TaskItem {
        try await Task.sleep(for: latency)
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
        try await Task.sleep(for: latency)
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            throw NetworkError.notFound
        }
        tasks[index] = task
        return task
    }

    func deleteTask(id: TaskItem.ID) async throws {
        try await Task.sleep(for: latency)
        guard tasks.contains(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        tasks.removeAll { $0.id == id }
    }
}

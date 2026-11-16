import Foundation
import Observation

/// State and actions for the task list: loading, filtering, completion, and deletion.
@Observable
@MainActor
final class TaskListViewModel {
    private(set) var tasks: [TaskItem] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    var errorMessage: String?
    var searchText = ""
    var filter: TaskFilter = .all

    private let taskService: any TaskServiceProtocol

    /// Creates the view model.
    init(taskService: any TaskServiceProtocol) {
        self.taskService = taskService
    }

    /// Tasks matching the current filter and search text.
    var visibleTasks: [TaskItem] {
        let query = searchText.trimmed
        return tasks.filter { task in
            let matchesFilter = switch filter {
            case .all: true
            case .active: !task.isCompleted
            case .completed: task.isCompleted
            }
            let matchesQuery = query.isEmpty
                || task.title.localizedCaseInsensitiveContains(query)
                || task.notes.localizedCaseInsensitiveContains(query)
            return matchesFilter && matchesQuery
        }
    }

    /// Whether an error occurred after the initial load (shown as an alert over existing content).
    var isErrorAlertPresented: Bool {
        get { errorMessage != nil && hasLoaded }
        set { if !newValue { errorMessage = nil } }
    }

    /// Loads tasks the first time the screen appears.
    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await loadTasks()
    }

    /// Fetches tasks from the service, replacing the current list.
    func loadTasks() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            tasks = try await taskService.fetchTasks()
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Toggles completion optimistically, reverting if the update fails.
    func toggleCompletion(of task: TaskItem) async {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }

        let original = tasks[index]
        var updated = original
        updated.isCompleted.toggle()
        tasks[index] = updated

        do {
            let saved = try await taskService.updateTask(updated)
            replace(saved)
        } catch {
            replace(original)
            errorMessage = error.localizedDescription
        }
    }

    /// Deletes a task optimistically, restoring it if the request fails.
    func delete(_ task: TaskItem) async {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }

        tasks.remove(at: index)

        do {
            try await taskService.deleteTask(id: task.id)
        } catch {
            tasks.insert(task, at: min(index, tasks.count))
            errorMessage = error.localizedDescription
        }
    }

    /// Inserts a task created elsewhere (e.g. the add-task sheet).
    func didCreate(_ task: TaskItem) {
        tasks.insert(task, at: 0)
    }

    /// Applies a change made elsewhere (e.g. the detail screen).
    func didUpdate(_ task: TaskItem) {
        replace(task)
    }

    /// Removes a task deleted elsewhere (e.g. the detail screen).
    func didDelete(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
    }

    private func replace(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
    }
}

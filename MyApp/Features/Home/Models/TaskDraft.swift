import Foundation

/// Fields required to create a new task.
struct TaskDraft: Codable, Equatable, Sendable {
    let title: String
    let notes: String
    let dueDate: Date?
    let priority: TaskPriority
}

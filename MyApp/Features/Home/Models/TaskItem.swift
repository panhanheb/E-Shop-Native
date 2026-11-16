import Foundation

/// A single to-do item. Named `TaskItem` to avoid clashing with Swift's `Task`.
struct TaskItem: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    var title: String
    var notes: String
    var dueDate: Date?
    var priority: TaskPriority
    var isCompleted: Bool
    let createdAt: Date
}

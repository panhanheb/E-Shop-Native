import Foundation

/// Relative importance of a task.
enum TaskPriority: String, Codable, CaseIterable, Identifiable, Sendable {
    case low
    case medium
    case high

    var id: Self { self }
}

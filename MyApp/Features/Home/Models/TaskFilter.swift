import Foundation

/// Which tasks the list should display.
enum TaskFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case active
    case completed

    var id: Self { self }
}

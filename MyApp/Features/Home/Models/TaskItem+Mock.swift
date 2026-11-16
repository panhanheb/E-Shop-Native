import Foundation

extension TaskItem {
    private static let day: TimeInterval = 86_400

    /// Sample tasks for previews, mock services, and tests.
    static let mocks: [TaskItem] = [
        TaskItem(
            id: UUID(),
            title: "Prepare sprint demo",
            notes: "Record a short walkthrough of the new onboarding flow.",
            dueDate: Date.now.addingTimeInterval(day),
            priority: .high,
            isCompleted: false,
            createdAt: Date.now.addingTimeInterval(-day)
        ),
        TaskItem(
            id: UUID(),
            title: "Buy groceries",
            notes: "Milk, eggs, coffee beans, spinach.",
            dueDate: Date.now.addingTimeInterval(day / 2),
            priority: .medium,
            isCompleted: false,
            createdAt: Date.now.addingTimeInterval(-2 * day)
        ),
        TaskItem(
            id: UUID(),
            title: "Renew passport",
            notes: "",
            dueDate: Date.now.addingTimeInterval(14 * day),
            priority: .low,
            isCompleted: false,
            createdAt: Date.now.addingTimeInterval(-3 * day)
        ),
        TaskItem(
            id: UUID(),
            title: "Review pull request #42",
            notes: "Focus on the networking layer changes.",
            dueDate: nil,
            priority: .medium,
            isCompleted: true,
            createdAt: Date.now.addingTimeInterval(-4 * day)
        ),
        TaskItem(
            id: UUID(),
            title: "Book dentist appointment",
            notes: "",
            dueDate: nil,
            priority: .low,
            isCompleted: true,
            createdAt: Date.now.addingTimeInterval(-5 * day)
        )
    ]

    /// A single sample task.
    static var mock: TaskItem { mocks[0] }
}

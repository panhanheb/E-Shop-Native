import Foundation

extension Endpoint {
    /// `GET /tasks`
    static let tasks = Endpoint(path: "tasks")

    /// `GET /tasks/{id}`
    static func task(id: TaskItem.ID) -> Endpoint {
        Endpoint(path: "tasks/\(id.uuidString)")
    }

    /// `POST /tasks`
    static func createTask(_ draft: TaskDraft) throws -> Endpoint {
        try Endpoint(path: "tasks", method: .post, body: draft)
    }

    /// `PUT /tasks/{id}`
    static func updateTask(_ task: TaskItem) throws -> Endpoint {
        try Endpoint(path: "tasks/\(task.id.uuidString)", method: .put, body: task)
    }

    /// `DELETE /tasks/{id}`
    static func deleteTask(id: TaskItem.ID) -> Endpoint {
        Endpoint(path: "tasks/\(id.uuidString)", method: .delete)
    }
}

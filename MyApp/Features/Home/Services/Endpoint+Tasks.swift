import Foundation

extension Endpoint {
    /// `GET /tasks`
    static let tasks = Endpoint(path: AppEndPoint.tasks)

    /// `GET /tasks/{id}`
    static func task(id: TaskItem.ID) -> Endpoint {
        Endpoint(path: AppEndPoint.task(id: id))
    }

    /// `POST /tasks`
    static func createTask(_ draft: TaskDraft) throws -> Endpoint {
        try Endpoint(path: AppEndPoint.tasks, method: .post, body: draft)
    }

    /// `PUT /tasks/{id}`
    static func updateTask(_ task: TaskItem) throws -> Endpoint {
        try Endpoint(path: AppEndPoint.task(id: task.id), method: .put, body: task)
    }

    /// `DELETE /tasks/{id}`
    static func deleteTask(id: TaskItem.ID) -> Endpoint {
        Endpoint(path: AppEndPoint.task(id: id), method: .delete)
    }
}

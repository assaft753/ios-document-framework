//
//  TaskDao.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 16/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
import SQLite

struct TaskDao {
    private let db: Connection
    
    public init(db: Connection) {
        self.db = db
    }
    
    public func insert(tasks: [Task]) throws -> [Int] {
        var ids: [Int] = []
        try db.transaction {
            ids.append(contentsOf: try tasks.map { try insert(task: $0) })
        }
        return ids
    }
    
    public func insert(task: Task) throws -> Int {
        Int(try db.run(TaskDao.table.insert(or: .replace,
                                            TaskDao.notificationId <- task.notificationId,
                                            TaskDao.notificationType <- task.notificationType,
                                            TaskDao.identifier <- task.identifier,
                                            TaskDao.data <- task.data)))
    }
    
    public func getAllTasks() -> [Task] {
        if let dbTasks = try? db.prepare(TaskDao.table) {
            return TaskDao.convertToTaskModelsFrom(rows: dbTasks)
        }
        return []
    }
    
    public func getTopTask() -> Task? {
        if let dbTasks = try? db.prepare(TaskDao.table.order(TaskDao.taskId.asc).limit(1)),
            let dbTask = dbTasks.first() {
            return TaskDao.convertToTaskModelFrom(row: dbTask)
        }
        return nil
    }
    
    public func getTaskBy(notificationId: String) -> Task? {
        if let dbTasks = try? db.prepare(TaskDao.table.filter(TaskDao.notificationId == notificationId).limit(1)),
            let dbTask = dbTasks.first() {
            return TaskDao.convertToTaskModelFrom(row: dbTask)
        }
        return nil
    }
    
    public func getTaskBy(identifier: Int) -> Task? {
        if let dbTasks = try? db.prepare(TaskDao.table.filter(TaskDao.identifier == identifier).limit(1)),
            let dbTask = dbTasks.first() {
            return TaskDao.convertToTaskModelFrom(row: dbTask)
        }
        return nil
    }
    
    public func getTaskBy(taskId: Int) -> Task? {
        if let dbTasks = try? db.prepare(TaskDao.table.filter(TaskDao.taskId == taskId)),
            let dbTask = dbTasks.first() {
            return TaskDao.convertToTaskModelFrom(row: dbTask)
        }
        return nil
    }
    
    public func getTaskBy(identifier: Int, notificationType: String) -> Task? {
        if let dbTasks = try? db.prepare(TaskDao.table.filter(TaskDao.identifier == identifier &&
            TaskDao.notificationType == notificationType).limit(1)),
            let dbTask = dbTasks.first() {
            return TaskDao.convertToTaskModelFrom(row: dbTask)
        }
        return nil
    }
    
    public func getTaskBy(notificationType: String) -> Task? {
        if let dbTasks = try? db.prepare(TaskDao.table.filter(TaskDao.notificationType == notificationType).limit(1)),
            let dbTask = dbTasks.first() {
            return TaskDao.convertToTaskModelFrom(row: dbTask)
        }
        return nil
    }
    
    public func getTasksBy(notificationType: String) -> [Task] {
        if let dbTasks = try? db.prepare(TaskDao.table.filter(TaskDao.notificationType == notificationType))
        {
            return TaskDao.convertToTaskModelsFrom(rows: dbTasks)
        }
        return []
    }
    
    public func deleteTasks() {
        let _ = try? db.run(TaskDao.table.delete())
    }
    
    public func deleteTaskBy(notificationId: String) {
        let _ = try? db.run(TaskDao.table.filter(TaskDao.notificationId == notificationId).delete())
    }
    
    public func deleteTasksBy(notificationType: String) {
        let _ = try? db.run(TaskDao.table.filter(TaskDao.notificationType == notificationType).delete())
    }
    
    public func deleteTaskBy(taskId: Int) {
        let _ = try? db.run(TaskDao.table.filter(TaskDao.taskId == taskId).delete())
    }
    
    public func deleteTaskBy(identifier: Int) {
        let _ = try? db.run(TaskDao.table.filter(TaskDao.identifier == identifier).delete())
    }
    
    public func deleteTasks(taskIds: [Int]) {
        let _ = try? db.run(TaskDao.table.filter(taskIds.contains(TaskDao.taskId)).delete())
    }
}

extension TaskDao {
    private static let table = Table("task")
    private static let taskId = Expression<Int>("task_id")
    private static let notificationId = Expression<String?>("notification_id")
    private static let notificationType = Expression<String>("type")
    private static let identifier = Expression<Int?>("identifier")
    private static let data = Expression<String?>("data")
    
    
    static func convertToTaskModelsFrom(rows: AnySequence<Row>) -> [Task] {
        return rows.map { convertToTaskModelFrom(row: $0) }
    }
    
    static func convertToTaskModelFrom(row: Row) -> Task {
        return Task(notificationType: row[TaskDao.notificationType], taskId: row[TaskDao.taskId] ,data: row[TaskDao.data], identifier: row[TaskDao.identifier], notificationId: row[TaskDao.notificationId])
    }
}

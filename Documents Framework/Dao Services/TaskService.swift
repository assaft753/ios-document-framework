//
//  TaskService.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 16/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation

struct TaskService {
    private static var _instance: TaskService!
    
    public static var shared: TaskService {
        _instance = _instance ?? TaskService()
        return _instance
    }
    
    private let taskDao: TaskDao
    private var locker: ReadWriteLock
    
    private init() {
        self.taskDao = TaskDao(db: Database.shared.db)
        self.locker = ReadWriteLock()
    }
    
    public func getTasks() -> [Task] {
        return locker.acquireReadLock {
            return taskDao.getAllTasks()
        }
    }
    
    public func getTopTask() -> Task? {
        return locker.acquireReadLock {
            return taskDao.getTopTask()
        }
    }
    
    public func moveTaskToEndOfQueue(task: inout Task) throws {
        return try locker.acquireWriteLock {
            let tempTask = Task(notificationType: task.notificationType, data: task.data, identifier: task.identifier, notificationId: task.notificationId)
            taskDao.deleteTaskBy(taskId: task.taskId)
            task.taskId = try taskDao.insert(task: tempTask)
        }
    }
    
    public func insert(task: inout Task) throws {
        try locker.acquireWriteLock {
            task.taskId = try taskDao.insert(task: task)
        }
    }
    
    public func insert(tasks: inout [Task]) throws {
        try locker.acquireWriteLock {
            let taskIds = try taskDao.insert(tasks: tasks)
            for index in 0..<tasks.count {
                tasks[index].taskId = taskIds[index]
            }
        }
    }
    public func deleteTasksBy(taskType: String) {
        locker.acquireWriteLock {
            taskDao.deleteTasksBy(notificationType: taskType)
        }
    }
    
    public func getTaskBy(notificationId: String) -> Task? {
        locker.acquireReadLock {
            taskDao.getTaskBy(notificationId: notificationId)
        }
    }
    
    public func getTaskBy(identifier: Int, notificationType: String) -> Task? {
        locker.acquireReadLock {
            taskDao.getTaskBy(identifier: identifier, notificationType: notificationType)
        }
    }
    
    public func getTaskBy(notificationType: String) -> Task? {
        locker.acquireReadLock {
            taskDao.getTaskBy(notificationType: notificationType)
        }
    }
    
    public func getTasksBy(notificationType: String) -> [Task] {
        locker.acquireReadLock {
            taskDao.getTasksBy(notificationType: notificationType)
        }
    }
    
    public func getTaskBy(identifier: Int) -> Task? {
        locker.acquireReadLock {
            taskDao.getTaskBy(identifier: identifier)
        }
    }
    
    public func getTaskBy(taskId: Int) -> Task? {
        locker.acquireReadLock {
            taskDao.getTaskBy(taskId: taskId)
        }
    }
    
    public func deleteTaskBy(notificationId: String) {
        locker.acquireReadLock {
            taskDao.deleteTaskBy(notificationId: notificationId)
        }
    }
    
    public func deleteTaskBy(identifier: Int) {
        locker.acquireReadLock {
            taskDao.deleteTaskBy(identifier: identifier)
        }
    }
    
    public func deleteTaskBy(taskId: Int) {
        locker.acquireReadLock {
            taskDao.deleteTaskBy(taskId: taskId)
        }
    }
    
    public func deleteTasksBy(taskIds: [Int]) {
        locker.acquireReadLock {
            taskDao.deleteTasks(taskIds: taskIds)
        }
    }
    
    //MARK: saveUploadTask method
    public func insertAnonymous(uploadTask: inout Task, taskData: [AnyHashable: Any], docUrl: String) throws {
        try locker.acquireWriteLock {
            let taskFolderName = "\(Int(Double(Date().timeIntervalSince1970) * 1000))_\(uploadTask.identifier!)"
            let taskFileName = "task.txt"
            let documentFileName = "document.pdf"
            
            let dstPath = DocumentService.docDirectory.appendingPathComponent("anonymous_files", isDirectory: true).appendingPathComponent(taskFolderName, isDirectory: true).normalizedAbsoluteString()
            
            if !FileService.shared.duplicate(srcPath: docUrl, dstPath: dstPath, dstFileName: documentFileName) {
                throw ErrorContainer(error: PODError.createFileError("Error in duplicating file"), track: Track.track(), message: "insertAnonymous")
            }
            
            var taskDataObj = taskData
            
            taskDataObj["external_doc_url"] = URL(string: taskFolderName)!.appendingPathComponent(documentFileName, isDirectory: false).normalizedAbsoluteString()
            
            uploadTask.data = String(data: try JSONSerialization.data(withJSONObject: taskDataObj), encoding: .utf8)!
            
            let taskObject = ["task": try JSONSerialization.jsonObject(with: try JSONEncoder().encode(uploadTask)) as! [String: Any]]
            
            if !FileService.shared.write(contents: try JSONSerialization.data(withJSONObject: taskObject), at: dstPath, fileName: taskFileName) {
                throw ErrorContainer(error: PODError.createFileError("Error in creating file"), track: Track.track(), message: "insertAnonymous")
            }
        }
    }
}

//
//  LogService.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 16/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation

struct LogService {
    private static var _instance: LogService!
    
    public static var shared: LogService {
        _instance = _instance ?? LogService()
        return _instance
    }
    
    private let logDao: LogDao
    private var locker: ReadWriteLock
    
    private init() {
        self.logDao = LogDao(db: Database.shared.db)
        self.locker = ReadWriteLock()
    }
    
    public func getLogs() -> [Log] {
        return locker.acquireReadLock {
            return logDao.getAllLogs()
        }
    }
    
    public func deleteLogs() {
        locker.acquireWriteLock {
            logDao.deleteLogs()
        }
    }
    
    public func insert(log: inout Log) throws {
        try locker.acquireWriteLock {
            log.logId = try logDao.insert(log: log)
        }
    }
    
    public func insert(logMessage: String, with severityStr: String) throws -> Log {
        return try locker.acquireWriteLock {
            var log = Log(message: logMessage, severity: Log.LogSeverity(rawValue: severityStr.lowercased()) ?? Log.LogSeverity.information)
            
            log.logId = try logDao.insert(log: log)
            return log
        }
    }
    
    public func insert(logMessage: String, with severity: Log.LogSeverity) throws -> Log {
        return try locker.acquireWriteLock {
            var log = Log(message: logMessage, severity: severity)
            log.logId = try logDao.insert(log: log)
            return log
        }
    }
    
    public func insert(logMessage: String, dateCreatedStr: String, with severity: Log.LogSeverity) throws -> Log {
        return try locker.acquireWriteLock {
            var log = Log(message: logMessage, severity: severity, createdTimeStamp: Date.convertFrom(date: dateCreatedStr)!.timeIntervalSince1970)
            log.logId = try logDao.insert(log: log)
            return log
        }
    }
    
    
    
}

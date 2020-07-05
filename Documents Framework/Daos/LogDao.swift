//
//  LogDao.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 15/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
import SQLite

struct LogDao {
    private let db: Connection
    
    public init(db: Connection) {
        self.db = db
    }
    
    public func insert(log: Log) throws -> Int {
        return try Int(db.run(LogDao.table.insert(
            or: .replace, LogDao.severity <- log.severity.rawValue,
            LogDao.message <- log.message,
            LogDao.createdDate <- log.createdTimeStampInMilliseconds)))
    }
    
    public func getAllLogs() -> [Log] {
        if let dbLogs = try? db.prepare(LogDao.table) {
            return LogDao.convertToLogModelsFrom(rows: dbLogs)
        }
        return []
    }
    
    public func getLogBy(id: Int) -> Log? {
        if let dbLogs = try? db.prepare(LogDao.table.filter(LogDao.logId == id)),
            let dbLog = dbLogs.first() {
            return LogDao.convertToLogModelFrom(row: dbLog)
        }
        return nil
    }
    
    public func deleteLogBy(id: Int) {
        let _ = try? db.run(LogDao.table.filter(LogDao.logId == id).delete())
    }
    
    public func deleteLogs() {
        let _ = try? db.run(LogDao.table.delete())
    }
}

extension LogDao {
    private static let table = Table("log")
    private static let logId = Expression<Int>("log_id")
    private static let severity = Expression<String>("severity")
    private static let createdDate = Expression<Int64>("created_date")
    private static let message = Expression<String>("message")
    
    static func convertToLogModelsFrom(rows: AnySequence<Row>) -> [Log] {
        return rows.map { convertToLogModelFrom(row: $0) }
    }
    
    static func convertToLogModelFrom(row: Row) -> Log {
        return Log(message: row[LogDao.message], severity: Log.LogSeverity(rawValue: row[LogDao.severity])!,
                   createdTimeStamp: Double(row[LogDao.createdDate]) / 1000, logId: row[LogDao.logId])
    }
}

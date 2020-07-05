//
//  Log.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 15/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation

struct Log {
    
    enum LogSeverity: String {
        case information
        case warning
        case error
        case fatal
    }
    
    var createdDate: Date {
        return Date(timeIntervalSince1970: createdTimeStamp)
    } // computed property, represent In Seconds
    
    var createdTimeStampInMilliseconds: Int64 {
        return Int64(createdTimeStamp * 1000)
    }
    var logId: Int
    var message: String
    var severity: LogSeverity
    var createdTimeStamp: Double // In Seconds
    
    init(message: String, severity: LogSeverity = .information, createdTimeStamp: Double = Date().timeIntervalSince1970,
         logId: Int = 0) {
        self.logId = logId
        self.message = message
        self.severity = severity
        self.createdTimeStamp = createdTimeStamp
    }
}

extension Log: Encodable {
    enum CodingKeys: String, CodingKey {
        case message
        case severity
        case dateCreated = "date_created"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.message, forKey: .message)
        try container.encode(self.severity.rawValue, forKey: .severity)
        try container.encode(self.createdTimeStampInMilliseconds, forKey: .dateCreated)
    }
}

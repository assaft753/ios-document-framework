//
//  Task.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 16/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation

struct Task {
    var taskId: Int
    var notificationId: String?
    var notificationType: String
    var identifier: Int?
    var data: String
    
    init(notificationType: String, taskId: Int = 0, data: String? = nil, identifier: Int? = nil, notificationId: String? = nil) {
        self.notificationType = notificationType
        self.data = data ?? "{}"
        self.identifier = identifier
        self.taskId = 0
        self.notificationId = notificationId
    }
}

extension Task: Codable {
    enum CodingKeys: String, CodingKey {
        case data
        case identifier
        case notificationId = "notification_id"
        case notificationType = "type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decodeIfPresent(String.self, forKey: .data) ?? "{}"
        self.identifier = try container.decodeIfPresent(Int.self, forKey: .identifier)
        self.notificationId = try container.decodeIfPresent(String.self, forKey: .notificationId)
        self.notificationType = try container.decode(String.self, forKey: .notificationType)
        self.taskId = 0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(notificationId, forKey: .notificationId)
        try container.encode(notificationType, forKey: .notificationType)
    }
}

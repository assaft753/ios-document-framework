//
//  Location.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 16/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
struct Location {
    var createdDate: Date {
        return Date(timeIntervalSince1970: createdTimeStamp)
    } // computed property, represent In Seconds
    
    var createdTimeStampInMilliseconds: Int64 {
        return Int64(createdTimeStamp * 1000)
    }
    
    var locationId: Int
    var longitude: Double
    var latitude: Double
    var createdTimeStamp: Double
    
    init(longitude: Double, latitude: Double,
         createdTimeStamp: Double = Date().timeIntervalSince1970, locationId: Int = 0) {
        self.longitude = longitude
        self.latitude = latitude
        self.createdTimeStamp = createdTimeStamp
        self.locationId = locationId
    }
}

extension Location: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case longitude
        case latitude
        case createdDate = "created_date"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(createdDate.convertToString(), forKey: .createdDate)
    }
}

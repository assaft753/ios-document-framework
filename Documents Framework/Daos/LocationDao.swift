//
//  LocationDao.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 16/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
import SQLite
struct LocationDao {
    private let db: Connection
    
    public init(db: Connection) {
        self.db = db
    }
    
    public func getAllLocations() -> [Location] {
        if let dbLocations = try? db.prepare(LocationDao.table) {
            return LocationDao.convertToLocationModelsFrom(rows: dbLocations)
        }
        return []
    }
    
    public func insert(location: Location) throws -> Int {
        return try Int(db.run(LocationDao.table.insert(or: .replace,
                                                       LocationDao.longitude <- location.longitude,
                                                       LocationDao.latitude <- location.latitude,
                                                       LocationDao.createdDate <- location.createdTimeStampInMilliseconds)))
    }
    
    public func deleteLocations() {
        _ = try? db.run(LocationDao.table.delete())
    }
    
    public func deleteLocationsBy(ids: [Int]) {
        _ = try? db.run(LocationDao.table.filter(ids.contains(LocationDao.locationId)).delete())
    }
}

extension LocationDao {
    private static let table = Table("location")
    private static let locationId = Expression<Int>("location_id")
    private static let longitude = Expression<Double>("longitude")
    private static let latitude = Expression<Double>("latitude")
    private static let createdDate = Expression<Int64>("created_date")
    
    
    static func convertToLocationModelsFrom(rows: AnySequence<Row>) -> [Location] {
        return rows.map { convertToLocationModelFrom(row: $0) }
    }
    
    static func convertToLocationModelFrom(row: Row) -> Location {
        Location(longitude: row[LocationDao.longitude], latitude: row[LocationDao.latitude],
                 createdTimeStamp: Double(row[LocationDao.createdDate]) / 1000, locationId: row[LocationDao.locationId])
    }
}

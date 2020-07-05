//
//  LocationService.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 16/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation

struct LocationService {
    private static var _instance: LocationService!
    
    public static var shared: LocationService {
        _instance = _instance ?? LocationService()
        return _instance
    }
    
    private let locationDao: LocationDao
    private var locker: ReadWriteLock
    
    private init() {
        self.locationDao = LocationDao(db: Database.shared.db)
        self.locker = ReadWriteLock()
    }
    
    public func getLocations() -> [Location] {
        return locker.acquireReadLock {
            return locationDao.getAllLocations()
        }
    }
    
    public func insert(location: inout Location) throws {
        return try locker.acquireWriteLock {
            location.locationId = try locationDao.insert(location: location)
        }
    }
    
    public func deleteLocations() {
        locker.acquireWriteLock {
            locationDao.deleteLocations()
        }
    }
    
    public func deleteLocations(by locationIds: [Int]){
        locker.acquireWriteLock {
            locationDao.deleteLocationsBy(ids: locationIds)
        }
    }
}

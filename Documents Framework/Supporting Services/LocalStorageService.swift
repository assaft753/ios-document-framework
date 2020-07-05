//
//  LocalStorageService.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 23/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
struct LocalStorageService {
    private static var _instance: LocalStorageService!
    
    public static var shared: LocalStorageService {
        _instance = _instance ?? LocalStorageService()
        return _instance
    }
    
    public func set<T>(for key: String, value: T) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    public func set<T>(forObject key: String, value: T) throws where T: Encodable {
        let decodedObject = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(value), options: [])
        UserDefaults.standard.set(decodedObject, forKey: key)
    }
    
    public func get<T>(for key:String) -> T? {
        return UserDefaults.standard.object(forKey: key) as? T
    }
    
    public func get<T>(for key:String, defaultValue: T) -> T {
        guard let value = UserDefaults.standard.object(forKey: key) as? T else {
            return defaultValue
        }
        return value
    }
    
    public func get<T>(forObject key:String) -> T? where T: Decodable {
        if let fromStorage = UserDefaults.standard.object(forKey: key),
        let data = try? JSONSerialization.data(withJSONObject: fromStorage, options: []),
            let object = try? JSONDecoder().decode(T.self, from: data) {
            return object
        }
        return nil
    }
    
    public func get<T>(forObject key:String, defaultValue: T) -> T where T: Decodable {
        if let fromStorage = UserDefaults.standard.object(forKey: key),
        let data = try? JSONSerialization.data(withJSONObject: fromStorage, options: []),
            let object = try? JSONDecoder().decode(T.self, from: data) {
            return object
        }
        return defaultValue
    }
    
    public func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

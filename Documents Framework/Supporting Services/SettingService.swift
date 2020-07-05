//
//  SettingService.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 23/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
struct SettingService {
    private static var _instance: SettingService!
    
    public static var shared: SettingService {
        _instance = _instance ?? SettingService()
        return _instance
    }
    
    private var locker: ReadWriteLock
    
    private init() {
        locker = ReadWriteLock()
    }
    
    func get() -> [Section] {
        return locker.acquireReadLock {
            LocalStorageService.shared.get(forObject: "sections", defaultValue: [])
        }
    }
    
    func getS() -> [Setting] {
        return locker.acquireReadLock {
            LocalStorageService.shared.get(forObject: "settings", defaultValue: [])
        }
    }
    
    func update(forSettingId settingId: Int, set settingValue: String) throws {
        var sections: [Section] = locker.acquireReadLock {
            LocalStorageService.shared.get(forObject: "sections", defaultValue: [])
        }
        
        if let sectionIndex = sections.firstIndex(where: { section in
            section.settings.contains {
                $0.settingId == settingId
            }
        })
        {
            
            let settingIndex = sections[sectionIndex].settings.firstIndex{
                $0.settingId == settingId
                }!
            
            sections[sectionIndex].settings[settingIndex].settingValue = settingValue
            
            try set(sections: sections)
        }
    }
    
    func set(sections: [Section]) throws {
        let flatSettings = convertToFlatSettings(sections: sections)
        
        try locker.acquireWriteLock {
            try LocalStorageService.shared.set(forObject: "settings", value: flatSettings)
            try LocalStorageService.shared.set(forObject: "sections", value: sections)
        }
    }
    
    private func convertToFlatSettings(sections: [Section]) -> [String: String] {
        var flatSettings: [String: String] = [:]
        sections.forEach {
            $0.settings.forEach {
                flatSettings[$0.settingKey] = $0.settingValue
            }
        }
        return flatSettings
    }
    
    func clear() {
        locker.acquireWriteLock {
            LocalStorageService.shared.remove(key: "settings")
            LocalStorageService.shared.remove(key: "sections")
        }
    }
    
    func createUpdateSettingTask(forSettingId settingId: Int, from currentSettingValue: String, to newSettingValue: String) throws {
        let updateSettingTaskData: [String: Any] = [
            "setting_id": settingId,
            "current_setting_value": currentSettingValue,
            "setting_value": newSettingValue
        ]
        
        var updateSettingTask = Task(notificationType: "UpdateSetting")
        updateSettingTask.data = String(data: try JSONSerialization.data(withJSONObject: updateSettingTaskData, options: []), encoding: .utf8)!
        
        try TaskService.shared.insert(task: &updateSettingTask)
    }
    
    //MARK: refreshSettings method
    func refreshSettings(toSaveSettings: Bool) throws -> [Section] {
        return try locker.acquireWriteLock {
            do {
                let sectionData = try PODNetworking().request(httpMethod: .GET, entryPoint: "setting")!
                let sections = try JSONDecoder().decode([Section].self, from: sectionData)
                
                if toSaveSettings {
                    try set(sections: sections)
                }
                
                return sections
            } catch HttpError.notAuthorizeError(let message) {
                //TODO: Add broadcast
                throw ErrorContainer(error: HttpError.notAuthorizeError(message: message), track: Track.track(), message: "refreshSettings")
            } catch {
                throw ErrorContainer(error: error, track: Track.track(), message: "refreshSettings")
            }
        }
    }
}

//
//  Setting.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 23/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
struct Setting {
    var settingId: Int
    var settingKey: String
    var settingType: String
    var valueType: String
    var settingValue: String
    var settingOptions: String
    var settingName: String
    var isWriteable: Bool
    
    init(settingId: Int, settingKey: String, settingType: String,
         valueType: String, settingValue: String, settingOptions: String,
         settingName: String, isWriteable: Bool) {
        self.settingId = settingId
        self.settingKey = settingKey
        self.settingType = settingType
        self.valueType = valueType
        self.settingValue = settingValue
        self.settingOptions = settingOptions
        self.settingName = settingName
        self.isWriteable = isWriteable
    }
}

extension Setting: Codable {}


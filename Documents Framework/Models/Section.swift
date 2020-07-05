//
//  Section.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 23/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
struct Section {
    var sectionId: Int
    var sectionName: String
    var settings: [Setting]
}

extension Section: Codable {}

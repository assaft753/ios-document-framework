//
//  Bool.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 11/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation

extension Bool {
    public var rawValue: Int {
        self ? 1 : 0
    }
}

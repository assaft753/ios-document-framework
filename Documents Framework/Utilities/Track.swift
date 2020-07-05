//
//  Track.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 25/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
struct Track: CustomStringConvertible {
    var description: String {
        return "called from \(function) \(file):\(rowNumber)"
    }
    
    let file: String
    let function: String
    let rowNumber: Int
    
    public static func track(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line ) -> Track {
        return Track(file: file, function: function, rowNumber: line)
    }
}

//
//  Date.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 16/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation

extension Date{
    public func convertToString(as format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS") -> String {
        let d1 = Date()
        let d2 = Date()
        
        let _ = d1 <= d2
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    public static func convertFrom(date string: String, as format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
}

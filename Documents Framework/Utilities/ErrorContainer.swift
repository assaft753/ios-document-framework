//
//  ErrorContainer.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 25/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
struct ErrorContainer: Error, CustomStringConvertible {
    var description: String {
        return "\(message), \(error), \(track)"
    }
    
    private let track: Track
    private let message: String
    public let error: Error
    
    init(error: Error, track: Track, message: String) {
        self.error = error
        self.track = track
        self.message = message
    }
}

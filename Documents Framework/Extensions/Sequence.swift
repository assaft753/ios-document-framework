//
//  Sequence.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 11/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation

extension Sequence
{
    public func first() -> Element? {
        return self.first { _ in true }
    }
    
    public func toArray() -> [Element] {
        return Array(self)
    }
}

//
//  URL.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 24/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
extension URL {
    public func normalizedAbsoluteString() -> String {
        return absoluteString.removingPercentEncoding!
    }
}

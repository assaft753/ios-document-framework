//
//  PODError.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 14/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
enum PODError: Error {
    case MetadataParseError(String)
    case podComponentsFromLocalStorageError(String)
    case createFileError(String)
}

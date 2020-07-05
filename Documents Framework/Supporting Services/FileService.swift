//
//  FileService.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 24/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
struct FileService {
    private static var _instance: FileService!
    public static var shared: FileService {
        _instance = _instance ?? FileService()
        return _instance
    }

    public func duplicate(srcPath: String, dstPath: String, dstFileName: String) -> Bool {
        if let srcFileUrl = URL(string: dstPath)?.appendingPathComponent(dstFileName, isDirectory: false) {
            do {
                try FileManager.default.createDirectory(atPath: dstPath, withIntermediateDirectories: true)
                try FileManager.default.copyItem(atPath: srcPath, toPath: srcFileUrl.normalizedAbsoluteString())
                return true
            } catch {
                print(error)
            }
        }
        return false
    }
    
    public func read(from filePath: String) -> Data? {
        return FileManager.default.contents(atPath: filePath)
    }
    
    public func write(contents: Data?, at filePath: String, fileName: String) -> Bool {
        do {
            if let fileUrl = URL(string: filePath)?.appendingPathComponent(fileName, isDirectory: false) {
                try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true)
                return FileManager.default.createFile(atPath: fileUrl.normalizedAbsoluteString(), contents: contents)
            }
            return false
        } catch {
            return false
        }
    }
    
    public func remove(at filePath: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: filePath)
            return true
        } catch {
            return false
        }
    }
}

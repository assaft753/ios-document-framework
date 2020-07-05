//
//  Database.swift
//  test
//
//  Created by Assaf Tayouri on 11/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
import SQLite

struct Database {
    
    private static var _instance: Database!
    
    static var shared: Database {
        _instance = _instance ?? Database()
        return _instance
    }
    
    let db: Connection
    private let migrationManager: SQLiteMigrationManager
    
    private init() {
        self.db = try! Connection(Database.storeURL().absoluteString)
        self.migrationManager = SQLiteMigrationManager(db: self.db, bundle: Database.migrationsBundle())
        try! migrateIfNeeded()
    }
    
    func migrateIfNeeded() throws {
        if !migrationManager.hasMigrationsTable() {
            try migrationManager.createMigrationsTable()
        }
        
        if migrationManager.needsMigration() {
            try migrationManager.migrateDatabase()
        }
    }
}

extension Database {
    static func storeURL() -> URL {
        guard let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]) else {
            fatalError("could not get user documents directory URL")
        }
        
        return documentsURL.appendingPathComponent("pod.sqlite")
    }
    
    // MARK: For migrations as swift files
    static func migrations() -> [Migration] {
        return []
    }
    
    static func migrationsBundle() -> Bundle {
        guard let bundleURL = Bundle.main.url(forResource: "Migrations", withExtension: "bundle") else {
            fatalError("could not find migrations bundle")
        }
        guard let bundle = Bundle(url: bundleURL) else {
            fatalError("could not load migrations bundle")
        }
        
        return bundle
    }
}

extension Database: CustomStringConvertible {
    var description: String {
        return "Database:\n" +
            "url: \(Database.storeURL().absoluteString)\n" +
            "migration state:\n" +
            "  hasMigrationsTable() \(migrationManager.hasMigrationsTable())\n" +
            "  currentVersion()     \(migrationManager.currentVersion())\n" +
            "  originVersion()      \(migrationManager.originVersion())\n" +
            "  appliedVersions()    \(migrationManager.appliedVersions())\n" +
            "  pendingMigrations()  \(migrationManager.pendingMigrations())\n" +
        "  needsMigration()     \(migrationManager.needsMigration())"
    }
}

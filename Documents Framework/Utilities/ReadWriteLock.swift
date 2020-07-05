//
//  ReadWriteLock.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 16/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation

public class ReadWriteLock {
    // MARK: Private Properties
    private var lock = pthread_rwlock_t()
    
    // MARK: Initialization
    public init() {
        pthread_rwlock_init(&lock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    // MARK: Public Methods
    public func acquireReadLock<R>(_ action: () throws -> R) rethrows -> R {
        pthread_rwlock_rdlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        
        return try action()
    }
    
    public func acquireWriteLock<R>(_ action: () throws -> R) rethrows -> R {
        pthread_rwlock_wrlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        
        return try action()
    }
}

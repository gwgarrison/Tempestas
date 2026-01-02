//
//  CacheEntry.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

struct CacheEntry<T: Codable>: Codable {
    let data: T
    let timestamp: Date
    let expirationInterval: TimeInterval
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > expirationInterval
    }
    
    init(data: T, expirationInterval: TimeInterval) {
        self.data = data
        self.timestamp = Date()
        self.expirationInterval = expirationInterval
    }
}

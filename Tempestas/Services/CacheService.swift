//
//  CacheService.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

class CacheService {
    static let shared = CacheService()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("WeatherCache", isDirectory: true)
        
        // Create cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Cache Constants
    
    struct CacheDuration {
        static let currentWeather: TimeInterval = 10 * 60 // 10 minutes
        static let hourlyForecast: TimeInterval = 60 * 60 // 1 hour
        static let dailyForecast: TimeInterval = 2 * 60 * 60 // 2 hours

        /// Seconds remaining until midnight — cache expires at the start of the next day
        static var untilEndOfDay: TimeInterval {
            let calendar = Calendar.current
            let now = Date()
            let midnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
            return midnight.timeIntervalSince(now)
        }
    }
    
    // MARK: - Cache Methods
    
    func cache<T: Codable>(_ data: T, forKey key: String, duration: TimeInterval) {
        let entry = CacheEntry(data: data, expirationInterval: duration)
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        
        do {
            let encoded = try JSONEncoder().encode(entry)
            try encoded.write(to: fileURL)
        } catch {
            print("Cache write failed: \(error.localizedDescription)")
        }
    }
    
    func retrieve<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)
            
            if entry.isExpired {
                removeCacheEntry(forKey: key)
                return nil
            }
            
            return entry.data
        } catch {
            print("Cache read failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    func removeCacheEntry(forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clearExpiredCache() {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for file in files {
            if let data = try? Data(contentsOf: file),
               let attributes = try? fileManager.attributesOfItem(atPath: file.path),
               let modificationDate = attributes[.modificationDate] as? Date {
                
                // Remove files older than 24 hours
                if Date().timeIntervalSince(modificationDate) > 24 * 60 * 60 {
                    try? fileManager.removeItem(at: file)
                }
            }
        }
    }
    
    func clearAllCache() {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for file in files {
            try? fileManager.removeItem(at: file)
        }
    }
}

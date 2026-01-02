//
//  StorageService.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let savedLocations = "savedLocations"
        static let userPreferences = "userPreferences"
    }
    
    private init() {}
    
    // MARK: - Saved Locations
    
    func saveSavedLocations(_ locations: [WeatherLocation]) {
        do {
            let encoded = try JSONEncoder().encode(locations)
            userDefaults.set(encoded, forKey: Keys.savedLocations)
        } catch {
            print("Failed to save locations: \(error.localizedDescription)")
        }
    }
    
    func loadSavedLocations() -> [WeatherLocation] {
        guard let data = userDefaults.data(forKey: Keys.savedLocations) else {
            return []
        }
        
        do {
            let locations = try JSONDecoder().decode([WeatherLocation].self, from: data)
            return locations
        } catch {
            print("Failed to load locations: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - User Preferences
    
    func savePreferences(_ preferences: UserPreferences) {
        do {
            let encoded = try JSONEncoder().encode(preferences)
            userDefaults.set(encoded, forKey: Keys.userPreferences)
        } catch {
            print("Failed to save preferences: \(error.localizedDescription)")
        }
    }
    
    func loadPreferences() -> UserPreferences {
        guard let data = userDefaults.data(forKey: Keys.userPreferences) else {
            return .default
        }
        
        do {
            let preferences = try JSONDecoder().decode(UserPreferences.self, from: data)
            return preferences
        } catch {
            print("Failed to load preferences: \(error.localizedDescription)")
            return .default
        }
    }
}

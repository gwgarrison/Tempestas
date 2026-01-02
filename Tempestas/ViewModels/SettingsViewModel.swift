//
//  SettingsViewModel.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var preferences: UserPreferences
    
    private let storageService = StorageService.shared
    
    init() {
        self.preferences = storageService.loadPreferences()
    }
    
    func updateTemperatureUnit(_ unit: TemperatureUnit) {
        preferences.temperatureUnit = unit
        savePreferences()
    }
    
    func updateWindSpeedUnit(_ unit: WindSpeedUnit) {
        preferences.windSpeedUnit = unit
        savePreferences()
    }
    
    func updateTimeFormat(_ format: TimeFormat) {
        preferences.timeFormat = format
        savePreferences()
    }
    
    private func savePreferences() {
        storageService.savePreferences(preferences)
    }
}

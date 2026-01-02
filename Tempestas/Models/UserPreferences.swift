//
//  UserPreferences.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

enum TemperatureUnit: String, Codable, CaseIterable {
    case fahrenheit = "°F"
    case celsius = "°C"
}

enum WindSpeedUnit: String, Codable, CaseIterable {
    case mph = "mph"
    case kmh = "km/h"
}

enum TimeFormat: String, Codable, CaseIterable {
    case twelveHour = "12-hour"
    case twentyFourHour = "24-hour"
}

struct UserPreferences: Codable {
    var temperatureUnit: TemperatureUnit
    var windSpeedUnit: WindSpeedUnit
    var timeFormat: TimeFormat
    
    static let `default` = UserPreferences(
        temperatureUnit: .fahrenheit,
        windSpeedUnit: .mph,
        timeFormat: .twelveHour
    )
}

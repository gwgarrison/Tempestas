//
//  WeatherMapService.swift
//  Tempestas
//

import Foundation
import SwiftUI

// MARK: - Map Layer Types

enum WeatherMapLayer: String, CaseIterable, Identifiable {
    case precipitation = "precipitation_new"
    case wind          = "wind_new"
    case temperature   = "temp_new"
    case humidity      = "humidity"
    case clouds        = "clouds_new"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .precipitation: return "Precipitation"
        case .wind:          return "Wind"
        case .temperature:   return "Temperature"
        case .humidity:      return "Humidity"
        case .clouds:        return "Clouds"
        }
    }

    var sfSymbol: String {
        switch self {
        case .precipitation: return "cloud.rain.fill"
        case .wind:          return "wind"
        case .temperature:   return "thermometer.medium"
        case .humidity:      return "humidity.fill"
        case .clouds:        return "cloud.fill"
        }
    }

    /// Gradient stops approximating OpenWeatherMap's tile color scale (low → high).
    var legendGradient: [Color] {
        switch self {
        case .precipitation:
            return [
                Color(red: 0.60, green: 0.85, blue: 1.00),
                Color(red: 0.20, green: 0.50, blue: 1.00),
                Color(red: 0.00, green: 0.10, blue: 0.80),
                Color(red: 0.50, green: 0.00, blue: 0.70)
            ]
        case .wind:
            return [
                Color(red: 0.20, green: 0.40, blue: 0.80),
                Color(red: 0.10, green: 0.80, blue: 0.80),
                Color(red: 0.20, green: 0.85, blue: 0.20),
                Color(red: 1.00, green: 0.85, blue: 0.00),
                Color(red: 1.00, green: 0.30, blue: 0.00)
            ]
        case .temperature:
            return [
                Color(red: 0.40, green: 0.00, blue: 0.60),
                Color(red: 0.10, green: 0.30, blue: 0.90),
                Color(red: 0.20, green: 0.80, blue: 0.80),
                Color(red: 0.20, green: 0.80, blue: 0.20),
                Color(red: 1.00, green: 0.85, blue: 0.00),
                Color(red: 1.00, green: 0.30, blue: 0.00)
            ]
        case .humidity:
            return [
                Color(red: 0.95, green: 0.95, blue: 0.60),
                Color(red: 0.50, green: 0.85, blue: 0.40),
                Color(red: 0.10, green: 0.55, blue: 0.20)
            ]
        case .clouds:
            return [
                Color(red: 0.95, green: 0.95, blue: 0.95),
                Color(red: 0.65, green: 0.65, blue: 0.70),
                Color(red: 0.30, green: 0.30, blue: 0.35)
            ]
        }
    }

    var legendMinLabel: String {
        switch self {
        case .precipitation: return "None"
        case .wind:          return "Calm"
        case .temperature:   return "Cold"
        case .humidity:      return "0%"
        case .clouds:        return "Clear"
        }
    }

    var legendMaxLabel: String {
        switch self {
        case .precipitation: return "Heavy"
        case .wind:          return "Storm"
        case .temperature:   return "Hot"
        case .humidity:      return "100%"
        case .clouds:        return "Overcast"
        }
    }
}

// MARK: - WeatherMapService

/// Provides OpenWeatherMap tile URLs.
/// Copy Secrets.example.plist to Secrets.plist and add your key from https://openweathermap.org/api
enum WeatherMapService {
    static let apiKey: String = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: Any],
              let key = dict["OpenWeatherMapAPIKey"] as? String else {
            return ""
        }
        return key
    }()

    static func tileURL(for layer: WeatherMapLayer, z: Int, x: Int, y: Int) -> URL {
        URL(string: "https://tile.openweathermap.org/map/\(layer.rawValue)/\(z)/\(x)/\(y).png?appid=\(apiKey)")!
    }
}

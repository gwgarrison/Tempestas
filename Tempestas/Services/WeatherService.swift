//
//  WeatherService.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation
import WeatherKit
import CoreLocation
import Combine

enum WeatherServiceError: Error {
    case locationUnavailable
    case weatherDataUnavailable
    case networkError
}

@MainActor
class WeatherService {
    private let service = WeatherKit.WeatherService.shared
    
    /// Fetch current weather for a location
    func fetchCurrentWeather(for location: WeatherLocation) async throws -> CurrentWeather {
        let coordinate = location.coordinate
        
        do {
            let weather = try await service.weather(for: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
            
            // WeatherKit returns temperatures in Celsius - convert to Fahrenheit for internal storage
            let celsiusToFahrenheit: (Double) -> Double = { celsius in
                return (celsius * 9/5) + 32
            }
            
            return CurrentWeather(
                temperature: celsiusToFahrenheit(weather.currentWeather.temperature.value),
                feelsLike: celsiusToFahrenheit(weather.currentWeather.apparentTemperature.value),
                condition: weather.currentWeather.condition.description,
                conditionCode: weather.currentWeather.symbolName,
                highTemp: celsiusToFahrenheit(weather.dailyForecast.first?.highTemperature.value ?? 0),
                lowTemp: celsiusToFahrenheit(weather.dailyForecast.first?.lowTemperature.value ?? 0),
                humidity: Int(weather.currentWeather.humidity * 100),
                windSpeed: weather.currentWeather.wind.speed.value,
                windDirection: Int(weather.currentWeather.wind.direction.value),
                uvIndex: weather.currentWeather.uvIndex.value,
                sunrise: weather.dailyForecast.first?.sun.sunrise ?? Date(),
                sunset: weather.dailyForecast.first?.sun.sunset ?? Date(),
                lastUpdated: Date()
            )
        } catch {
            print("❌ WeatherKit Error: \(error)")
            print("❌ Error localized: \(error.localizedDescription)")
            throw WeatherServiceError.weatherDataUnavailable
        }
    }
    
    /// Fetch hourly forecast for a location
    func fetchHourlyForecast(for location: WeatherLocation) async throws -> [HourlyForecast] {
        let coordinate = location.coordinate
        
        do {
            let weather = try await service.weather(for: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
            
            // WeatherKit returns temperatures in Celsius - convert to Fahrenheit for internal storage
            let celsiusToFahrenheit: (Double) -> Double = { celsius in
                return (celsius * 9/5) + 32
            }
            
            let now = Date()
            let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
            
            return weather.hourlyForecast.filter { $0.date >= now && $0.date <= endOfDay }
                .prefix(12)
                .map { forecast in
                    HourlyForecast(
                        time: forecast.date,
                        temperature: celsiusToFahrenheit(forecast.temperature.value),
                        condition: forecast.condition.description,
                        conditionCode: forecast.symbolName,
                        precipitationChance: Int(forecast.precipitationChance * 100)
                    )
                }
        } catch {
            print("❌ WeatherKit Hourly Error: \(error)")
            throw WeatherServiceError.weatherDataUnavailable
        }
    }
    
    /// Fetch daily forecast for a location
    func fetchDailyForecast(for location: WeatherLocation) async throws -> [DailyForecast] {
        let coordinate = location.coordinate
        
        do {
            let weather = try await service.weather(for: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
            
            // WeatherKit returns temperatures in Celsius - convert to Fahrenheit for internal storage
            let celsiusToFahrenheit: (Double) -> Double = { celsius in
                return (celsius * 9/5) + 32
            }
            
            return weather.dailyForecast
                .dropFirst() // Skip today
                .prefix(3)
                .map { forecast in
                    DailyForecast(
                        date: forecast.date,
                        highTemp: celsiusToFahrenheit(forecast.highTemperature.value),
                        lowTemp: celsiusToFahrenheit(forecast.lowTemperature.value),
                        condition: forecast.condition.description,
                        conditionCode: forecast.symbolName,
                        precipitationChance: Int(forecast.precipitationChance * 100)
                    )
                }
        } catch {
            print("❌ WeatherKit Daily Error: \(error)")
            throw WeatherServiceError.weatherDataUnavailable
        }
    }
}

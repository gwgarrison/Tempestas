//
//  WeatherService.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation
import WeatherKit
import CoreLocation

enum WeatherServiceError: Error {
    case locationUnavailable
    case weatherDataUnavailable
    case networkError
}

@MainActor
class WeatherService: ObservableObject {
    private let weatherService = WeatherService.shared
    
    /// Fetch current weather for a location
    func fetchCurrentWeather(for location: WeatherLocation) async throws -> CurrentWeather {
        let coordinate = location.coordinate
        
        do {
            let weather = try await weatherService.weather(for: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
            
            return CurrentWeather(
                temperature: weather.currentWeather.temperature.value,
                feelsLike: weather.currentWeather.apparentTemperature.value,
                condition: weather.currentWeather.condition.description,
                conditionCode: weather.currentWeather.symbolName,
                highTemp: weather.dailyForecast.first?.highTemperature.value ?? 0,
                lowTemp: weather.dailyForecast.first?.lowTemperature.value ?? 0,
                humidity: Int(weather.currentWeather.humidity * 100),
                windSpeed: weather.currentWeather.wind.speed.value,
                windDirection: Int(weather.currentWeather.wind.direction.value),
                uvIndex: weather.currentWeather.uvIndex.value,
                sunrise: weather.dailyForecast.first?.sun.sunrise ?? Date(),
                sunset: weather.dailyForecast.first?.sun.sunset ?? Date(),
                lastUpdated: Date()
            )
        } catch {
            throw WeatherServiceError.weatherDataUnavailable
        }
    }
    
    /// Fetch hourly forecast for a location
    func fetchHourlyForecast(for location: WeatherLocation) async throws -> [HourlyForecast] {
        let coordinate = location.coordinate
        
        do {
            let weather = try await weatherService.weather(for: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
            
            let now = Date()
            let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
            
            return weather.hourlyForecast.filter { $0.date >= now && $0.date <= endOfDay }
                .prefix(12)
                .map { forecast in
                    HourlyForecast(
                        time: forecast.date,
                        temperature: forecast.temperature.value,
                        condition: forecast.condition.description,
                        conditionCode: forecast.symbolName,
                        precipitationChance: Int(forecast.precipitationChance * 100)
                    )
                }
        } catch {
            throw WeatherServiceError.weatherDataUnavailable
        }
    }
    
    /// Fetch daily forecast for a location
    func fetchDailyForecast(for location: WeatherLocation) async throws -> [DailyForecast] {
        let coordinate = location.coordinate
        
        do {
            let weather = try await service.weather(for: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
            
            return weather.dailyForecast
                .dropFirst() // Skip today
                .prefix(3)
                .map { forecast in
                    DailyForecast(
                        date: forecast.date,
                        highTemp: forecast.highTemperature.value,
                        lowTemp: forecast.lowTemperature.value,
                        condition: forecast.condition.description,
                        conditionCode: forecast.symbolName,
                        precipitationChance: Int(forecast.precipitationChance * 100)
                    )
                }
        } catch {
            throw WeatherServiceError.weatherDataUnavailable
        }
    }
}

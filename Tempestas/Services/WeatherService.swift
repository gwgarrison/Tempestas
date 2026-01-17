//
//  WeatherService.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation
import WeatherKit
import CoreLocation

class WeatherService {
    private let service = WeatherKit.WeatherService.shared
    
    func fetchCurrentWeather(for location: WeatherLocation) async throws -> CurrentWeather {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        async let currentTask = service.weather(for: clLocation, including: .current)
        async let dailyTask = service.weather(for: clLocation, including: .daily)
        
        let (weather, daily) = try await (currentTask, dailyTask)
        
        let today = daily.forecast.first { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
        
        // Explicitly convert to Celsius to ensure consistent unit in Model
        return CurrentWeather(
            temperature: weather.temperature.converted(to: .celsius).value,
            feelsLike: weather.apparentTemperature.converted(to: .celsius).value,
            condition: weather.condition.description,
            conditionCode: weather.symbolName,
            highTemp: today?.highTemperature.converted(to: .celsius).value ?? 0,
            lowTemp: today?.lowTemperature.converted(to: .celsius).value ?? 0,
            humidity: Int(weather.humidity * 100),
            windSpeed: weather.wind.speed.value,
            windDirection: Int(weather.wind.direction.value),
            uvIndex: weather.uvIndex.value,
            sunrise: today?.sun.sunrise ?? Date(),
            sunset: today?.sun.sunset ?? Date(),
            lastUpdated: Date()
        )
    }
    
    func fetchHourlyForecast(for location: WeatherLocation) async throws -> [HourlyForecast] {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let weather = try await service.weather(for: clLocation, including: .hourly)
        
        let now = Date()
        let end = now.addingTimeInterval(24 * 3600)
        
        return weather.forecast
            .filter { $0.date >= now && $0.date <= end }
            .map {
                HourlyForecast(
                    time: $0.date,
                    temperature: $0.temperature.converted(to: .celsius).value,
                    condition: $0.condition.description,
                    conditionCode: $0.symbolName,
                    precipitationChance: Int($0.precipitationChance * 100)
                )
            }
    }
    
    func fetchDailyForecast(for location: WeatherLocation) async throws -> [DailyForecast] {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let weather = try await service.weather(for: clLocation, including: .daily)
        
        return weather.forecast.prefix(8).map {
            DailyForecast(
                date: $0.date,
                highTemp: $0.highTemperature.converted(to: .celsius).value,
                lowTemp: $0.lowTemperature.converted(to: .celsius).value,
                condition: $0.condition.description,
                conditionCode: $0.symbolName,
                precipitationChance: Int($0.precipitationChance * 100)
            )
        }
    }
    
    func fetchDayTemperatureStatistics(for location: WeatherLocation) async throws -> DayTemperatureStatistics? {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        print("📊 Fetching historical statistics for \(location.name)...")
        
        // Use DailyWeatherStatisticsQuery to get climate normals
        let now = Date()
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now)!
        print("📅 Day of year: \(dayOfYear)")
        
        print("⚠️ Historical statistics API unavailable in this build environment. Returning nil.")
        return nil
    }
}

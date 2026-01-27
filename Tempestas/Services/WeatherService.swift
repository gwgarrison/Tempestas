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
        
        do {
            // UNCOMMENT BELOW BLOCK if using Xcode 16+ / iOS 18 SDK
            /*
            let statistics = try await service.weather(for: clLocation, including: .daily)
            
            print("✅ Retrieved \(statistics.count) statistics entries")
            
            if let todayStats = statistics.first(where: { $0.day == dayOfYear }) {
                print("✅ Found stats for today: H:\(todayStats.temperature.averageHighTemperature) L:\(todayStats.temperature.averageLowTemperature)")
                return todayStats.temperature
            } else {
                print("⚠️ No statistics found for day \(dayOfYear)")
                // Fallback debug: print first few available days
                if let first = statistics.first {
                    print("ℹ️ First available day: \(first.day)")
                }
                return nil
            }
           */
            print("⚠️ Code commented out for build safety. Uncomment in WeatherService.swift to enable.")
            return nil
        } catch {
            print("❌ Failed to fetch daily statistics: \(error)")
            // Fallback for older SDKs or errors: return nil
            return nil
        }
    }
    
    private struct OpenMeteoResponse: Codable {
        let daily: DailyData
    }
    
    private struct DailyData: Codable {
        let time: [String]
        let temperature_2m_max: [Double?]
        let temperature_2m_min: [Double?]
    }
    
    private struct OpenMeteoClimateResponse: Codable {
        let daily: ClimateDailyData
    }
    
    private struct ClimateDailyData: Codable {
        let time: [String]
        let temperature_2m_max: [Double?]
        let temperature_2m_min: [Double?]
        let precipitation_sum: [Double?]
    }
    
    func fetchHistoricalAverages(for location: WeatherLocation) async -> DailyStatistics? {
        // Calculate date range: Last 10 years
        let calendar = Calendar.current
        let today = Date()
        guard let tenYearsAgo = calendar.date(byAdding: .year, value: -10, to: today),
              let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = dateFormatter.string(from: tenYearsAgo)
        let endDate = dateFormatter.string(from: yesterday)
        
        let urlString = "https://archive-api.open-meteo.com/v1/archive?latitude=\(location.latitude)&longitude=\(location.longitude)&start_date=\(startDate)&end_date=\(endDate)&daily=temperature_2m_max,temperature_2m_min&timezone=auto"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            
            // Filter for matching Month/Day
            let targetMonth = calendar.component(.month, from: today)
            let targetDay = calendar.component(.day, from: today)
            
            var maxTemps: [Double] = []
            var minTemps: [Double] = []
            
            for (index, dateString) in response.daily.time.enumerated() {
                if let date = dateFormatter.date(from: dateString) {
                    let month = calendar.component(.month, from: date)
                    let day = calendar.component(.day, from: date)
                    
                    if month == targetMonth && day == targetDay {
                        if index < response.daily.temperature_2m_max.count, let max = response.daily.temperature_2m_max[index] {
                            maxTemps.append(max)
                        }
                        if index < response.daily.temperature_2m_min.count, let min = response.daily.temperature_2m_min[index] {
                            minTemps.append(min)
                        }
                    }
                }
            }
            
            guard !maxTemps.isEmpty, !minTemps.isEmpty else { return nil }
            
            let avgMax = maxTemps.reduce(0, +) / Double(maxTemps.count)
            let avgMin = minTemps.reduce(0, +) / Double(minTemps.count)
            
            // Open-Meteo returns Celsius
            return DailyStatistics(
                averageHighTemperature: Measurement(value: avgMax, unit: .celsius),
                averageLowTemperature: Measurement(value: avgMin, unit: .celsius)
            )
            
        } catch {
            print("❌ OpenMeteo fetch failed: \(error)")
            return nil
        }
    }
    
    func fetchClimateStats(for location: WeatherLocation) async -> [MonthlyClimateStats] {
        // Calculate date range: Last 10 full years (e.g. 2014-2023 if today is 2024)
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)
        let startYear = currentYear - 11
        let endYear = currentYear - 1
        
        // Updated URL to fetch max and min temperatures
        let urlString = "https://archive-api.open-meteo.com/v1/archive?latitude=\(location.latitude)&longitude=\(location.longitude)&start_date=\(startYear)-01-01&end_date=\(endYear)-12-31&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=auto"
        
        guard let url = URL(string: urlString) else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OpenMeteoClimateResponse.self, from: data)
            
            var monthlyMaxTempSums = [Int: Double]()
            var monthlyMinTempSums = [Int: Double]()
            var monthlyPrecipSums = [Int: Double]()
            var monthlyCounts = [Int: Int]()
            
            // Initialize
            for m in 1...12 {
                monthlyMaxTempSums[m] = 0
                monthlyMinTempSums[m] = 0
                monthlyPrecipSums[m] = 0
                monthlyCounts[m] = 0
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            for (index, dateString) in response.daily.time.enumerated() {
                guard let date = dateFormatter.date(from: dateString),
                      let maxTemp = response.daily.temperature_2m_max[index],
                      let minTemp = response.daily.temperature_2m_min[index],
                      let precip = response.daily.precipitation_sum[index] else {
                    continue
                }
                
                let month = calendar.component(.month, from: date)
                
                monthlyMaxTempSums[month, default: 0] += maxTemp
                monthlyMinTempSums[month, default: 0] += minTemp
                monthlyPrecipSums[month, default: 0] += precip
                monthlyCounts[month, default: 0] += 1
            }
            
            var stats: [MonthlyClimateStats] = []
            let monthSymbols = dateFormatter.shortMonthSymbols ?? []
            
            for m in 1...12 {
                let count = Double(monthlyCounts[m] ?? 1)
                
                // Average monthly precip = Total Sum / 10 years
                let numberOfYears = 10.0
                
                let avgMaxTemp = (monthlyMaxTempSums[m] ?? 0) / (count > 0 ? count : 1)
                let avgMinTemp = (monthlyMinTempSums[m] ?? 0) / (count > 0 ? count : 1)
                let avgPrecip = (monthlyPrecipSums[m] ?? 0) / numberOfYears
                
                let monthName = (m <= monthSymbols.count) ? monthSymbols[m-1] : "\(m)"
                
                stats.append(MonthlyClimateStats(
                    month: m,
                    monthName: monthName,
                    averageHighTemperature: avgMaxTemp,
                    averageLowTemperature: avgMinTemp,
                    averagePrecipitation: avgPrecip
                ))
            }
            
            return stats
            
        } catch {
            print("❌ Failed to fetch climate stats: \(error)")
            return []
        }
    }
}

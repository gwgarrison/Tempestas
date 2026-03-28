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
        async let airQualityTask = fetchAirQuality(for: location)

        let (weather, daily) = try await (currentTask, dailyTask)
        let airQuality = await airQualityTask

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
            lastUpdated: Date(),
            airQualityIndex: airQuality?.index,
            airQualityCategory: airQuality?.category
        )
    }

    private struct OpenMeteoAirQualityResponse: Codable {
        let current: AirQualityCurrent
        struct AirQualityCurrent: Codable {
            let us_aqi: Int?
        }
    }

    private func fetchAirQuality(for location: WeatherLocation) async -> (index: Int, category: String)? {
        let urlString = "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=\(location.latitude)&longitude=\(location.longitude)&current=us_aqi"
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OpenMeteoAirQualityResponse.self, from: data)
            guard let aqi = response.current.us_aqi else { return nil }
            return (index: aqi, category: aqiCategory(for: aqi))
        } catch {
            print("❌ Air quality fetch failed: \(error)")
            return nil
        }
    }

    private func aqiCategory(for index: Int) -> String {
        switch index {
        case 0...50:    return "Good"
        case 51...100:  return "Moderate"
        case 101...150: return "Unhealthy for Sensitive Groups"
        case 151...200: return "Unhealthy"
        case 201...300: return "Very Unhealthy"
        default:        return "Hazardous"
        }
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
                    precipitationChance: Int($0.precipitationChance * 100),
                    windSpeed: $0.wind.speed.converted(to: .kilometersPerHour).value,
                    uvIndex: $0.uvIndex.value
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
                precipitationChance: Int($0.precipitationChance * 100),
                moonPhase: $0.moon.phase.description,
                moonPhaseSymbol: moonPhaseSymbol(for: $0.moon.phase)
            )
        }
    }
    
    private func moonPhaseSymbol(for phase: WeatherKit.MoonPhase) -> String {
        switch phase {
        case .new:             return "moonphase.new.moon"
        case .waxingCrescent:  return "moonphase.waxing.crescent"
        case .firstQuarter:    return "moonphase.first.quarter"
        case .waxingGibbous:   return "moonphase.waxing.gibbous"
        case .full:            return "moonphase.full.moon"
        case .waningGibbous:   return "moonphase.waning.gibbous"
        case .lastQuarter:     return "moonphase.last.quarter"
        case .waningCrescent:  return "moonphase.waning.crescent"
        @unknown default:      return "moon.fill"
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
        // Fetch from 1980 to yesterday for all-time records and 10-year averages
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let startDate = "1980-01-01"
        let endDate = dateFormatter.string(from: yesterday)
        let tenYearsAgoYear = currentYear - 10

        let urlString = "https://archive-api.open-meteo.com/v1/archive?latitude=\(location.latitude)&longitude=\(location.longitude)&start_date=\(startDate)&end_date=\(endDate)&daily=temperature_2m_max,temperature_2m_min&timezone=auto"

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)

            // Filter for matching Month/Day
            let targetMonth = calendar.component(.month, from: today)
            let targetDay = calendar.component(.day, from: today)

            var recentMaxTemps: [Double] = []
            var recentMinTemps: [Double] = []
            var allTimeMaxTemps: [Double] = []
            var allTimeMinTemps: [Double] = []

            for (index, dateString) in response.daily.time.enumerated() {
                if let date = dateFormatter.date(from: dateString) {
                    let month = calendar.component(.month, from: date)
                    let day = calendar.component(.day, from: date)
                    let year = calendar.component(.year, from: date)

                    if month == targetMonth && day == targetDay {
                        if index < response.daily.temperature_2m_max.count, let max = response.daily.temperature_2m_max[index] {
                            allTimeMaxTemps.append(max)
                            if year >= tenYearsAgoYear { recentMaxTemps.append(max) }
                        }
                        if index < response.daily.temperature_2m_min.count, let min = response.daily.temperature_2m_min[index] {
                            allTimeMinTemps.append(min)
                            if year >= tenYearsAgoYear { recentMinTemps.append(min) }
                        }
                    }
                }
            }

            guard !allTimeMaxTemps.isEmpty, !allTimeMinTemps.isEmpty else { return nil }

            let maxList = recentMaxTemps.isEmpty ? allTimeMaxTemps : recentMaxTemps
            let minList = recentMinTemps.isEmpty ? allTimeMinTemps : recentMinTemps
            let avgMax = maxList.reduce(0, +) / Double(maxList.count)
            let avgMin = minList.reduce(0, +) / Double(minList.count)
            let allTimeHigh = allTimeMaxTemps.max()!
            let allTimeLow = allTimeMinTemps.min()!

            // Open-Meteo returns Celsius
            return DailyStatistics(
                averageHighTemperature: Measurement(value: avgMax, unit: .celsius),
                averageLowTemperature: Measurement(value: avgMin, unit: .celsius),
                allTimeHigh: Measurement(value: allTimeHigh, unit: .celsius),
                allTimeLow: Measurement(value: allTimeLow, unit: .celsius)
            )

        } catch {
            print("❌ OpenMeteo fetch failed: \(error)")
            return nil
        }
    }
    
    func fetchClimateStats(for location: WeatherLocation) async -> [MonthlyClimateStats] {
        // Define Periods
        // Recent: Last 10 full years (e.g. 2014-2023 if today is 2024)
        // Historical: 1980 - 1999 (20 years)
        
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)
        
        // Recent Period
        let recentStartYear = currentYear - 11
        let recentEndYear = currentYear - 1
        
        // Historical Period
        let histStartYear = 1980
        let histEndYear = 1999
        
        // Fetch from the earliest start date (1980) to the latest end date
        let urlString = "https://archive-api.open-meteo.com/v1/archive?latitude=\(location.latitude)&longitude=\(location.longitude)&start_date=\(histStartYear)-01-01&end_date=\(recentEndYear)-12-31&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=auto"
        
        guard let url = URL(string: urlString) else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OpenMeteoClimateResponse.self, from: data)
            
            // Recent Accumulators
            var recentMaxTempSums = [Int: Double]()
            var recentMinTempSums = [Int: Double]()
            var recentPrecipSums = [Int: Double]()
            var recentCounts = [Int: Int]()
            
            // Historical Accumulators
            var histMaxTempSums = [Int: Double]()
            var histMinTempSums = [Int: Double]()
            var histPrecipSums = [Int: Double]()
            var histCounts = [Int: Int]()
            
            // Initialize
            for m in 1...12 {
                recentMaxTempSums[m] = 0
                recentMinTempSums[m] = 0
                recentPrecipSums[m] = 0
                recentCounts[m] = 0
                
                histMaxTempSums[m] = 0
                histMinTempSums[m] = 0
                histPrecipSums[m] = 0
                histCounts[m] = 0
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
                
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                
                if year >= recentStartYear && year <= recentEndYear {
                    // Add to Recent
                    recentMaxTempSums[month, default: 0] += maxTemp
                    recentMinTempSums[month, default: 0] += minTemp
                    recentPrecipSums[month, default: 0] += precip
                    recentCounts[month, default: 0] += 1
                } else if year >= histStartYear && year <= histEndYear {
                    // Add to Historical
                    histMaxTempSums[month, default: 0] += maxTemp
                    histMinTempSums[month, default: 0] += minTemp
                    histPrecipSums[month, default: 0] += precip
                    histCounts[month, default: 0] += 1
                }
            }
            
            var stats: [MonthlyClimateStats] = []
            let monthSymbols = dateFormatter.shortMonthSymbols ?? []
            
            for m in 1...12 {
                // Recent Calculations
                let rCount = Double(recentCounts[m] ?? 1)
                let rYears = 10.0 // Recent period is 10 years fixed for precip division
                
                let avgMaxTemp = (recentMaxTempSums[m] ?? 0) / (rCount > 0 ? rCount : 1)
                let avgMinTemp = (recentMinTempSums[m] ?? 0) / (rCount > 0 ? rCount : 1)
                // Use actual count or fixed? Precip is usually Total / Years.
                // Using 10.0 is safe for 'Average Monthly Precip' over a 10 year period.
                let avgPrecip = (recentPrecipSums[m] ?? 0) / rYears
                
                // Historical Calculations
                let hCount = Double(histCounts[m] ?? 1)
                let histMaxTemp = (histMaxTempSums[m] ?? 0) / (hCount > 0 ? hCount : 1)
                let histMinTemp = (histMinTempSums[m] ?? 0) / (hCount > 0 ? hCount : 1)
                let histAvgPrecip = (histPrecipSums[m] ?? 0) / 20.0  // 1980–1999 = 20 years

                let monthName = (m <= monthSymbols.count) ? monthSymbols[m-1] : "\(m)"

                stats.append(MonthlyClimateStats(
                    month: m,
                    monthName: monthName,
                    averageHighTemperature: avgMaxTemp,
                    averageLowTemperature: avgMinTemp,
                    averagePrecipitation: avgPrecip,
                    historicalHighTemperature: histMaxTemp,
                    historicalLowTemperature: histMinTemp,
                    historicalPrecipitation: histAvgPrecip
                ))
            }
            
            return stats
            
        } catch {
            print("❌ Failed to fetch climate stats: \(error)")
            return []
        }
    }
}

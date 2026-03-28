//
//  BestTimeOutsideView.swift
//  Tempestas
//

import SwiftUI

struct BestTimeOutsideView: View {
    let hourlyForecast: [HourlyForecast]
    let preferences: UserPreferences
    var airQualityIndex: Int? = nil

    private struct OutdoorWindow {
        let start: Date
        let end: Date
        let avgPrecipChance: Int
        let avgUVIndex: Int
        let conditionCode: String
        let score: Double
    }

    private var bestWindow: OutdoorWindow? {
        let calendar = Calendar.current
        // Only consider daytime hours (6 AM – 9 PM)
        let daytimeHours = hourlyForecast.filter {
            let hour = calendar.component(.hour, from: $0.time)
            return hour >= 6 && hour < 21
        }

        guard daytimeHours.count >= 3 else { return nil }

        var bestScore = -Double.infinity
        var bestIndex = 0

        for i in 0...(daytimeHours.count - 3) {
            let score = [daytimeHours[i], daytimeHours[i+1], daytimeHours[i+2]]
                .map { hourScore($0) }
                .reduce(0, +) / 3.0
            if score > bestScore {
                bestScore = score
                bestIndex = i
            }
        }

        guard bestScore >= 20 else { return nil }

        let window = [daytimeHours[bestIndex], daytimeHours[bestIndex+1], daytimeHours[bestIndex+2]]
        return OutdoorWindow(
            start: window[0].time,
            end: window[2].time.addingTimeInterval(3600),
            avgPrecipChance: window.map(\.precipitationChance).reduce(0, +) / 3,
            avgUVIndex: window.map(\.uvIndex).reduce(0, +) / 3,
            conditionCode: window[1].conditionCode,
            score: bestScore
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Best Time to Be Outside")
                .font(.headline)
                .padding(.horizontal)

            if let window = bestWindow {
                HStack(spacing: 16) {
                    Image(systemName: window.conditionCode)
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                        .frame(width: 50)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(window.start.formatted(timeFormat: preferences.timeFormat)) – \(window.end.formatted(timeFormat: preferences.timeFormat))")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(conditionSummary(precipChance: window.avgPrecipChance, uvIndex: window.avgUVIndex))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            } else {
                Text("Conditions aren't great for being outside today.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    // Score from 0–100; higher = better conditions for being outside
    private func hourScore(_ forecast: HourlyForecast) -> Double {
        var score = 100.0

        // Precipitation is the most important factor
        score -= Double(forecast.precipitationChance)

        // Penalty for dangerously high UV
        if forecast.uvIndex > 7 {
            score -= Double(forecast.uvIndex - 7) * 8
        }

        // Temperature comfort (values stored in Celsius)
        let temp = forecast.temperature
        if temp < 5       { score -= 20 }
        else if temp < 15 { score -= 10 }
        else if temp > 32 { score -= 20 }
        else if temp > 27 { score -= 8  }

        // Air quality penalty (AQI doesn't vary hourly, applied uniformly)
        if let aqi = airQualityIndex {
            if aqi > 200      { score -= 60 }
            else if aqi > 150 { score -= 40 }
            else if aqi > 100 { score -= 25 }
            else if aqi > 50  { score -= 10 }
        }

        return max(0, score)
    }

    private func conditionSummary(precipChance: Int, uvIndex: Int) -> String {
        var parts: [String] = []

        if precipChance < 20 {
            parts.append("Low chance of rain")
        } else if precipChance < 50 {
            parts.append("\(precipChance)% chance of rain")
        }

        if uvIndex >= 8 {
            parts.append("high UV – use sunscreen")
        } else if uvIndex >= 6 {
            parts.append("moderate UV")
        }

        if let aqi = airQualityIndex {
            if aqi > 200      { parts.append("very unhealthy air quality") }
            else if aqi > 150 { parts.append("unhealthy air quality") }
            else if aqi > 100 { parts.append("air quality unhealthy for sensitive groups") }
            else if aqi > 50  { parts.append("moderate air quality") }
        }

        return parts.isEmpty ? "Best window for the day" : parts.joined(separator: ", ")
    }
}

//
//  ClimateView.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import SwiftUI
import Charts

struct ClimateView: View {
    let stats: [MonthlyClimateStats]
    let preferences: UserPreferences
    
    private var recentYearRange: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        return "\(currentYear - 11)–\(currentYear - 1)"
    }
    
    private var currentMonthStats: MonthlyClimateStats? {
        let currentMonth = Calendar.current.component(.month, from: Date())
        return stats.first { $0.month == currentMonth }
    }

    var body: some View {
        VStack(spacing: 24) {
            if stats.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading climate data...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                // Current Month Highlight Card
                if let current = currentMonthStats {
                    let isFahrenheit = preferences.temperatureUnit == .fahrenheit
                    let highAnomalyC = current.averageHighTemperature - current.historicalHighTemperature
                    let lowAnomalyC  = current.averageLowTemperature  - current.historicalLowTemperature
                    let avgAnomalyC  = (highAnomalyC + lowAnomalyC) / 2.0
                    let displayAnomaly = isFahrenheit ? (avgAnomalyC * 9/5) : avgAnomalyC
                    let tempUnit = isFahrenheit ? "°F" : "°C"
                    let anomalyDir = displayAnomaly >= 0 ? "warmer" : "cooler"

                    let recentPrecip = isFahrenheit ? current.averagePrecipitation * 0.0393701 : current.averagePrecipitation
                    let histPrecip   = isFahrenheit ? current.historicalPrecipitation * 0.0393701 : current.historicalPrecipitation
                    let precipPct    = histPrecip > 0 ? ((recentPrecip - histPrecip) / histPrecip) * 100 : 0
                    let precipDir    = precipPct >= 0 ? "more" : "less"

                    let isWarmer = avgAnomalyC >= 0
                    let accent: Color = isWarmer ? .orange : .blue

                    VStack(alignment: .leading, spacing: 8) {
                        Text(current.monthName)
                            .font(.headline)
                            .foregroundColor(accent)
                        Text(String(format: "%.1f%@ %@ than historical average", abs(displayAnomaly), tempUnit, anomalyDir))
                            .font(.subheadline)
                        Text(String(format: "%.0f%% %@ precipitation than historical", abs(precipPct), precipDir))
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(accent.opacity(0.12))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(accent.opacity(0.3), lineWidth: 1))
                }

                // Temperature Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Average Temperature")
                        .font(.headline)
                    
                    // Legend Key
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 16) {
                            // Recent (Solid)
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.primary)
                                    .frame(width: 20, height: 3)
                                Text("\(recentYearRange) Average")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            // Historical (Dashed)
                            HStack(spacing: 6) {
                                HStack(spacing: 3) {
                                    ForEach(0..<3) { _ in
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(Color.primary.opacity(0.5))
                                            .frame(width: 4, height: 3)
                                    }
                                }
                                .frame(width: 20)
                                
                                Text("1980–1999 Average")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Circle().fill(Color.orange).frame(width: 6, height: 6)
                                Text("High").font(.caption).foregroundColor(.secondary)
                            }
                            HStack(spacing: 6) {
                                Circle().fill(Color.blue).frame(width: 6, height: 6)
                                Text("Low").font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.bottom, 4)
                    
                    let isFahrenheit = preferences.temperatureUnit == .fahrenheit
                    let unitLabel = isFahrenheit ? "°F" : "°C"
                    
                    Chart(stats) { stat in
                        let highTemp = isFahrenheit ? (stat.averageHighTemperature * 9/5) + 32 : stat.averageHighTemperature
                        let lowTemp = isFahrenheit ? (stat.averageLowTemperature * 9/5) + 32 : stat.averageLowTemperature
                        
                        let histHighTemp = isFahrenheit ? (stat.historicalHighTemperature * 9/5) + 32 : stat.historicalHighTemperature
                        let histLowTemp = isFahrenheit ? (stat.historicalLowTemperature * 9/5) + 32 : stat.historicalLowTemperature
                        
                        // Historical High Line (Dashed)
                        LineMark(
                            x: .value("Month", stat.monthName),
                            y: .value("Temp", histHighTemp),
                            series: .value("Series", "Hist High")
                        )
                        .foregroundStyle(Color.orange.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        
                        // Historical Low Line (Dashed)
                        LineMark(
                            x: .value("Month", stat.monthName),
                            y: .value("Temp", histLowTemp),
                            series: .value("Series", "Hist Low")
                        )
                        .foregroundStyle(Color.blue.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        
                        // Recent High Temp Line (Solid)
                        LineMark(
                            x: .value("Month", stat.monthName),
                            y: .value("Temp", highTemp),
                            series: .value("Series", "High")
                        )
                        .foregroundStyle(Color.orange)
                        
                        PointMark(
                             x: .value("Month", stat.monthName),
                             y: .value("Temp", highTemp)
                        )
                        .foregroundStyle(Color.orange)
                        
                        // Recent Low Temp Line (Solid)
                        LineMark(
                            x: .value("Month", stat.monthName),
                            y: .value("Temp", lowTemp),
                            series: .value("Series", "Low")
                        )
                        .foregroundStyle(Color.blue)
                        
                        PointMark(
                             x: .value("Month", stat.monthName),
                             y: .value("Temp", lowTemp)
                        )
                        .foregroundStyle(Color.blue)
                    }
                    .chartLegend(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartYScale(domain: .automatic(includesZero: false))
                    .frame(height: 250)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                
                // Precipitation Chart
                VStack(alignment: .leading, spacing: 12) {
                    let isFahrenheit = preferences.temperatureUnit == .fahrenheit
                    let unitLabel = isFahrenheit ? "(in)" : "(mm)"

                    Text("Average Precipitation \(unitLabel)")
                        .font(.headline)

                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.blue).frame(width: 20, height: 10)
                            Text("\(recentYearRange) Average").font(.caption).fontWeight(.medium)
                        }
                        HStack(spacing: 6) {
                            HStack(spacing: 3) {
                                ForEach(0..<3) { _ in
                                    RoundedRectangle(cornerRadius: 1).fill(Color.blue.opacity(0.5)).frame(width: 4, height: 3)
                                }
                            }
                            .frame(width: 20)
                            Text("1980–1999 Average").font(.caption).fontWeight(.medium).foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 4)

                    Chart(stats) { stat in
                        let precip     = isFahrenheit ? stat.averagePrecipitation * 0.0393701 : stat.averagePrecipitation
                        let histPrecip = isFahrenheit ? stat.historicalPrecipitation * 0.0393701 : stat.historicalPrecipitation
                        BarMark(x: .value("Month", stat.monthName), y: .value("Precip", precip))
                            .foregroundStyle(Color.blue.gradient)
                        LineMark(x: .value("Month", stat.monthName), y: .value("Precip", histPrecip),
                                 series: .value("Series", "Hist Precip"))
                            .foregroundStyle(Color.blue.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    }
                    .chartLegend(.hidden)
                    .frame(height: 250)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

                // Temperature Anomaly Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Temperature Anomaly")
                        .font(.headline)
                    Text("\(recentYearRange) average high vs. 1980–1999 baseline. Orange = warmer, blue = cooler.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)

                    let isFahrenheit = preferences.temperatureUnit == .fahrenheit
                    let unitLabel = isFahrenheit ? "°F" : "°C"

                    Chart(stats) { stat in
                        let anomalyC = stat.averageHighTemperature - stat.historicalHighTemperature
                        let anomaly  = isFahrenheit ? (anomalyC * 9/5) : anomalyC
                        BarMark(x: .value("Month", stat.monthName), y: .value("Anomaly (\(unitLabel))", anomaly))
                            .foregroundStyle(anomaly >= 0 ? Color.orange : Color.blue)
                        RuleMark(y: .value("Zero", 0))
                            .foregroundStyle(Color.primary.opacity(0.3))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                    .chartLegend(.hidden)
                    .chartYAxis { AxisMarks(position: .leading) }
                    .frame(height: 200)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
}

#Preview {
    let stats = [
        MonthlyClimateStats(month: 1, monthName: "Jan", averageHighTemperature: 15.0, averageLowTemperature: 8.0, averagePrecipitation: 50.0, historicalHighTemperature: 14.0, historicalLowTemperature: 7.0, historicalPrecipitation: 45.0),
        MonthlyClimateStats(month: 2, monthName: "Feb", averageHighTemperature: 16.0, averageLowTemperature: 9.0, averagePrecipitation: 45.0, historicalHighTemperature: 15.0, historicalLowTemperature: 8.0, historicalPrecipitation: 50.0),
        MonthlyClimateStats(month: 3, monthName: "Mar", averageHighTemperature: 18.0, averageLowTemperature: 11.0, averagePrecipitation: 40.0, historicalHighTemperature: 17.0, historicalLowTemperature: 10.0, historicalPrecipitation: 38.0),
    ]
    return ClimateView(stats: stats, preferences: .default)
}

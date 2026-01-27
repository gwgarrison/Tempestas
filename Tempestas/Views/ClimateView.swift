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
                // Temperature Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Average Temperature")
                        .font(.headline)
                    
                    let isFahrenheit = preferences.temperatureUnit == .fahrenheit
                    let unitLabel = isFahrenheit ? "°F" : "°C"
                    
                    Chart(stats) { stat in
                        let highTemp = isFahrenheit ? (stat.averageHighTemperature * 9/5) + 32 : stat.averageHighTemperature
                        let lowTemp = isFahrenheit ? (stat.averageLowTemperature * 9/5) + 32 : stat.averageLowTemperature
                        
                        // High Temp Line
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
                        
                        // Low Temp Line
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
                    .chartLegend(position: .top, alignment: .leading) {
                        HStack {
                            Label("Avg High", systemImage: "circle.fill").foregroundColor(.orange)
                            Label("Avg Low", systemImage: "circle.fill").foregroundColor(.blue)
                        }
                        .font(.caption)
                    }
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
                    
                    Chart(stats) { stat in
                        let precip = isFahrenheit ? stat.averagePrecipitation * 0.0393701 : stat.averagePrecipitation
                        
                        BarMark(
                            x: .value("Month", stat.monthName),
                            y: .value("Precip", precip)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                    .frame(height: 250)
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
        MonthlyClimateStats(month: 1, monthName: "Jan", averageHighTemperature: 15.0, averageLowTemperature: 8.0, averagePrecipitation: 50.0),
        MonthlyClimateStats(month: 2, monthName: "Feb", averageHighTemperature: 16.0, averageLowTemperature: 9.0, averagePrecipitation: 45.0),
        MonthlyClimateStats(month: 3, monthName: "Mar", averageHighTemperature: 18.0, averageLowTemperature: 11.0, averagePrecipitation: 40.0),
    ]
    return ClimateView(stats: stats, preferences: .default)
}

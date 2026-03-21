//
//  HistoricalComparisonsView.swift
//  Tempestas
//
//  Created by Gary Garrison on 1/5/26.
//

import SwiftUI
// import WeatherKit

struct HistoricalComparisonsView: View {
    let statistics: DailyStatistics
    let preferences: UserPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Historical Context")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Average High
                ComparisonRow(
                    label: "Average High",
                    value: statistics.averageHighTemperature,
                    icon: "thermometer.sun",
                    preferences: preferences
                )

                Divider()

                // Average Low
                ComparisonRow(
                    label: "Average Low",
                    value: statistics.averageLowTemperature,
                    icon: "thermometer.snowflake",
                    preferences: preferences
                )

                Divider()

                // All-Time High
                ComparisonRow(
                    label: "All-Time High",
                    value: statistics.allTimeHigh,
                    icon: "thermometer.high",
                    preferences: preferences
                )

                Divider()

                // All-Time Low
                ComparisonRow(
                    label: "All-Time Low",
                    value: statistics.allTimeLow,
                    icon: "thermometer.low",
                    preferences: preferences
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

struct ComparisonRow: View {
    let label: String
    let value: Measurement<UnitTemperature>
    let icon: String
    let preferences: UserPreferences
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text(value.formatted(unit: preferences.temperatureUnit == .fahrenheit ? .fahrenheit : .celsius))
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding()
    }
}

// Extension to help formatting measurement with preference
extension Measurement where UnitType == UnitTemperature {
    func formatted(unit: UnitTemperature) -> String {
        let converted = self.converted(to: unit)
        return String(format: "%.1f°", converted.value)
    }
}

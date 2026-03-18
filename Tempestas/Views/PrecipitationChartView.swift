//
//  PrecipitationChartView.swift
//  Tempestas
//

import SwiftUI
import Charts

struct PrecipitationChartView: View {
    let hourlyForecast: [HourlyForecast]
    let preferences: UserPreferences

    private var displayHours: [HourlyForecast] {
        Array(hourlyForecast.prefix(12))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Precipitation Chance")
                .font(.headline)
                .padding(.horizontal)

            if displayHours.allSatisfy({ $0.precipitationChance == 0 }) {
                Text("No precipitation expected in the next 12 hours.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Chart(displayHours) { forecast in
                    BarMark(
                        x: .value("Time", forecast.time, unit: .hour),
                        y: .value("Chance", forecast.precipitationChance)
                    )
                    .foregroundStyle(.blue.gradient)
                    .cornerRadius(3)
                }
                .chartYScale(domain: 0...100)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(hourLabel(for: date))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("\(v)%")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 140)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func hourLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = preferences.timeFormat == .twelveHour ? "ha" : "HH"
        return formatter.string(from: date)
    }
}

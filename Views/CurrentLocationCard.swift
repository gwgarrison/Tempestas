//
//  CurrentLocationCard.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import SwiftUI

struct CurrentLocationCard: View {
    let location: WeatherLocation
    let weather: CurrentWeather?
    @State private var preferences = StorageService.shared.loadPreferences()
    
    var body: some View {
        VStack(spacing: 16) {
            // Location Header
            HStack {
                Image(systemName: "location.fill")
                    .font(.caption)
                Text(location.name)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.secondary)
            
            if let weather = weather {
                // Weather Icon
                Image(systemName: weather.conditionCode)
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                // Temperature
                Text(weather.temperature.formatted(unit: preferences.temperatureUnit))
                    .font(.system(size: 64, weight: .light))
                
                // Condition
                Text(weather.condition)
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                // High/Low
                HStack(spacing: 16) {
                    Text("H: \(weather.highTemp.formatted(unit: preferences.temperatureUnit))")
                    Text("L: \(weather.lowTemp.formatted(unit: preferences.temperatureUnit))")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                // Feels Like
                Text("Feels like \(weather.feelsLike.formatted(unit: preferences.temperatureUnit))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ProgressView()
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    CurrentLocationCard(
        location: WeatherLocation(name: "San Francisco", latitude: 37.7749, longitude: -122.4194, isCurrentLocation: true),
        weather: CurrentWeather(
            temperature: 72,
            feelsLike: 70,
            condition: "Sunny",
            conditionCode: "sun.max.fill",
            highTemp: 78,
            lowTemp: 65,
            humidity: 65,
            windSpeed: 8,
            windDirection: 315,
            uvIndex: 6,
            sunrise: Date(),
            sunset: Date(),
            lastUpdated: Date()
        ),
        preferences: UserPreferences.default
    )
}

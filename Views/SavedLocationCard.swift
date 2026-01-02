//
//  SavedLocationCard.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import SwiftUI

struct SavedLocationCard: View {
    let location: WeatherLocation
    let weather: CurrentWeather?
    let preferences: UserPreferences
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                
                // Display actual temperature or placeholder
                if let weather = weather {
                    Text(weather.temperature.formatted(unit: preferences.temperatureUnit))
                        .font(.title2)
                        .foregroundColor(.primary)
                } else {
                    Text("--°")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Display actual weather icon or placeholder
            if let weather = weather {
                Image(systemName: weather.conditionCode)
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    SavedLocationCard(
        location: WeatherLocation(name: "New York, NY", latitude: 40.7128, longitude: -74.0060),
        weather: nil,
        preferences: UserPreferences.default
    )
}

//  WeatherDetailView.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import SwiftUI

struct WeatherDetailView: View {
    let location: WeatherLocation
    @ObservedObject var viewModel: WeatherViewModel
    let preferences: UserPreferences
    var onDeleteLocation: ((WeatherLocation) -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var selectedTab: DetailViewMode = .forecast
    
    enum DetailViewMode: String, CaseIterable, Identifiable {
        case forecast = "Forecast"
        case climate = "Climate"
        var id: String { rawValue }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Mode", selection: $selectedTab) {
                    ForEach(DetailViewMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if selectedTab == .forecast {
                    // Hero Section
                    if let weather = viewModel.currentWeather {
                        WeatherHeroSection(weather: weather, preferences: preferences)
                    }

                    // Best Time to Be Outside
                    if !viewModel.hourlyForecast.isEmpty {
                        BestTimeOutsideView(hourlyForecast: viewModel.hourlyForecast, preferences: preferences)
                    }

                    // Hourly Forecast
                    if !viewModel.hourlyForecast.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Forecast")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.hourlyForecast) { forecast in
                                        HourlyForecastCard(forecast: forecast, preferences: preferences)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Precipitation Chart
                    if !viewModel.hourlyForecast.isEmpty {
                        PrecipitationChartView(hourlyForecast: viewModel.hourlyForecast, preferences: preferences)
                    }

                    // 7-Day Forecast
                    if !viewModel.dailyForecast.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("7-Day Forecast")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.dailyForecast) { forecast in
                                DailyForecastCard(forecast: forecast, preferences: preferences)
                            }
                        }
                    }
                    
                    // Historical Context
                    if let statistics = viewModel.dayTemperatureStatistics {
                        HistoricalComparisonsView(statistics: statistics, preferences: preferences)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Historical Context")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text("Historical data unavailable.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Weather Details
                    if let weather = viewModel.currentWeather {
                        WeatherDetailsSection(
                            weather: weather,
                            preferences: preferences,
                            moonPhase: viewModel.dailyForecast.first?.moonPhase,
                            moonPhaseSymbol: viewModel.dailyForecast.first?.moonPhaseSymbol
                        )
                    }
                    
                    // Last Updated
                    if let lastUpdated = viewModel.lastUpdated {
                        Text("Updated \(lastUpdated.relativeTime())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    // Climate View
                    ClimateView(stats: viewModel.climateStats, preferences: preferences)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.fetchWeatherData(for: location)
        }
        .task {
            await viewModel.fetchWeatherData(for: location)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog("Remove this location?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                if let onDeleteLocation = onDeleteLocation {
                    onDeleteLocation(location)
                }
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove \(location.name) from your saved locations.")
        }
    }
}

// MARK: - Hero Section

struct WeatherHeroSection: View {
    let weather: CurrentWeather
    let preferences: UserPreferences
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: weather.conditionCode)
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text(weather.temperature.formatted(unit: preferences.temperatureUnit))
                .font(.system(size: 64, weight: .light))
            
            Text(weather.condition)
                .font(.title2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Text("H: \(weather.highTemp.formatted(unit: preferences.temperatureUnit))")
                Text("L: \(weather.lowTemp.formatted(unit: preferences.temperatureUnit))")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            Text("Feels like \(weather.feelsLike.formatted(unit: preferences.temperatureUnit))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Hourly Forecast Card

struct HourlyForecastCard: View {
    let forecast: HourlyForecast
    let preferences: UserPreferences
    
    var body: some View {
        VStack(spacing: 8) {
            Text(forecast.time.formatted(timeFormat: preferences.timeFormat))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Image(systemName: forecast.conditionCode)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(forecast.temperature.formatted(unit: preferences.temperatureUnit))
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if forecast.precipitationChance > 0 {
                Text("\(forecast.precipitationChance)%")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .frame(width: 60)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Daily Forecast Card

struct DailyForecastCard: View {
    let forecast: DailyForecast
    let preferences: UserPreferences
    
    var body: some View {
        HStack {
            Text(forecast.date.dayName())
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)
            
            Image(systemName: forecast.conditionCode)
                .font(.title3)
                .foregroundColor(.blue)
            
            Spacer()
            
            if forecast.precipitationChance > 0 {
                Text("\(forecast.precipitationChance)%")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 8) {
                Text("H: \(forecast.highTemp.formatted(unit: preferences.temperatureUnit))")
                Text("L: \(forecast.lowTemp.formatted(unit: preferences.temperatureUnit))")
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Weather Details Section

struct WeatherDetailsSection: View {
    let weather: CurrentWeather
    let preferences: UserPreferences
    var moonPhase: String? = nil
    var moonPhaseSymbol: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                WeatherDetailRow(
                    icon: "drop.fill",
                    title: "Humidity",
                    value: "\(weather.humidity)%"
                )

                Divider()

                WeatherDetailRow(
                    icon: "wind",
                    title: "Wind",
                    value: "\(weather.windSpeed.formatted(windUnit: preferences.windSpeedUnit)) \(weather.windDirection.toCardinalDirection())"
                )

                Divider()

                WeatherDetailRow(
                    icon: "sun.max.fill",
                    title: "UV Index",
                    value: "\(weather.uvIndex)"
                )

                Divider()

                WeatherDetailRow(
                    icon: "sunrise.fill",
                    title: "Sunrise",
                    value: weather.sunrise.formatted(timeFormat: preferences.timeFormat)
                )

                Divider()

                WeatherDetailRow(
                    icon: "sunset.fill",
                    title: "Sunset",
                    value: weather.sunset.formatted(timeFormat: preferences.timeFormat)
                )

                if let phase = moonPhase, let symbol = moonPhaseSymbol, !phase.isEmpty {
                    Divider()

                    WeatherDetailRow(
                        icon: symbol,
                        title: "Moon Phase",
                        value: phase
                    )
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

struct WeatherDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding()
    }
}

#Preview {
    let prefs = UserPreferences.default
    return NavigationStack {
        WeatherDetailView(
            location: WeatherLocation(name: "San Francisco", latitude: 37.7749, longitude: -122.4194),
            viewModel: WeatherViewModel(),
            preferences: prefs,
            onDeleteLocation: { _ in }
        )
    }
}

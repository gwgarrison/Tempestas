//
//  WeatherViewModel.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation
import CoreLocation
import Combine
import WeatherKit

@MainActor
class WeatherViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentLocation: WeatherLocation?
    @Published var savedLocations: [WeatherLocation] = []
    @Published var currentWeather: CurrentWeather?
    @Published var hourlyForecast: [HourlyForecast] = []
    @Published var dailyForecast: [DailyForecast] = []
    @Published var dayTemperatureStatistics: DailyStatistics?
    @Published var climateStats: [MonthlyClimateStats] = []
    @Published var savedLocationsWeather: [UUID: CurrentWeather] = [:]
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    // MARK: - Services
    
    private let weatherService = WeatherService()
    private let locationService = LocationService()
    private let cacheService = CacheService.shared
    private let storageService = StorageService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(runSetup: Bool = true) {
        loadSavedLocations()
        if runSetup {
            setupLocationBindings()
            Task {
                await setupLocation()
                await fetchSavedLocationsWeather()
            }
        }
    }
    
    private func setupLocationBindings() {
        locationService.$currentLocation
            .compactMap { $0 }
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] location in
                Task {
                    await self?.updateCurrentLocation(from: location)
                }
            }
            .store(in: &cancellables)
            
        locationService.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .denied || status == .restricted {
                    self?.errorMessage = "Location permission denied. Please enable it in Settings."
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Location Setup
    
    func setupLocation() async {
        print("🔍 Starting location setup...")
        locationService.requestLocationPermission()
        
        // If already authorized, request location immediately
        if locationService.authorizationStatus == .authorizedWhenInUse ||
           locationService.authorizationStatus == .authorizedAlways {
            print("📍 already authorized, requesting location...")
            locationService.requestLocation()
        }
    }
    
    func updateCurrentLocation(from clLocation: CLLocation) async {
        print("📍 Updating current location...")
        
        // Resolve city name
        let cityName = await locationService.resolveCityName(for: clLocation)
        let displayName = cityName ?? "Current Location"
        print("📍 Resolved city name: \(displayName)")
        
        let location = WeatherLocation(
            name: displayName,
            latitude: clLocation.coordinate.latitude,
            longitude: clLocation.coordinate.longitude,
            isCurrentLocation: true
        )
        
        currentLocation = location
        await fetchWeatherData(for: location)
    }
    
    // MARK: - Weather Data Fetching
    
    func fetchWeatherData(for location: WeatherLocation) async {
        print("🌤️ Fetching weather for: \(location.name)")
        isLoading = true
        errorMessage = nil
        
        let locationKey = "\(location.latitude),\(location.longitude)"
        
        // Try cache first
        if let cached = cacheService.retrieve(forKey: "current_\(locationKey)", as: CurrentWeather.self) {
            print("💾 Using cached current weather")
            currentWeather = cached
        }
        
        if let cached = cacheService.retrieve(forKey: "hourly_\(locationKey)", as: [HourlyForecast].self) {
            print("💾 Using cached hourly forecast")
            hourlyForecast = cached
        }
        
        if let cached = cacheService.retrieve(forKey: "daily_\(locationKey)", as: [DailyForecast].self) {
            print("💾 Using cached daily forecast")
            dailyForecast = cached
        }
        
        // Fetch fresh data
        do {
            print("🌐 Fetching current weather from WeatherKit...")
            let current = try await weatherService.fetchCurrentWeather(for: location)
            print("✅ Got current weather: \(current.temperature)°")
            currentWeather = current
            cacheService.cache(current, forKey: "current_\(locationKey)", duration: CacheService.CacheDuration.currentWeather)
            
            print("🌐 Fetching hourly forecast...")
            let hourly = try await weatherService.fetchHourlyForecast(for: location)
            print("✅ Got \(hourly.count) hourly forecasts")
            hourlyForecast = hourly
            cacheService.cache(hourly, forKey: "hourly_\(locationKey)", duration: CacheService.CacheDuration.hourlyForecast)

            if var updated = currentWeather {
                let todayHourly = hourly.filter { Calendar.current.isDateInToday($0.time) }
                if !todayHourly.isEmpty {
                    updated.highTemp = todayHourly.map { $0.temperature }.max() ?? updated.highTemp
                    updated.lowTemp = todayHourly.map { $0.temperature }.min() ?? updated.lowTemp
                    currentWeather = updated
                    cacheService.cache(updated, forKey: "current_\(locationKey)", duration: CacheService.CacheDuration.currentWeather)
                }
            }

            print("🌐 Fetching daily forecast...")
            let daily = try await weatherService.fetchDailyForecast(for: location)
            print("✅ Got \(daily.count) daily forecasts")
            dailyForecast = daily
            cacheService.cache(daily, forKey: "daily_\(locationKey)", duration: CacheService.CacheDuration.dailyForecast)
            
            // Historical statistics — cached until end of day
            if let cached = cacheService.retrieve(forKey: "historical_\(locationKey)", as: DailyStatistics.self) {
                print("💾 Using cached historical statistics")
                dayTemperatureStatistics = cached
            } else {
                print("🌐 Fetching historical statistics...")
                let stats = await weatherService.fetchHistoricalAverages(for: location)
                if let stats = stats {
                    print("✅ Got historical statistics: \(stats.averageHighTemperature) / \(stats.averageLowTemperature)")
                    cacheService.cache(stats, forKey: "historical_\(locationKey)", duration: CacheService.CacheDuration.untilEndOfDay)
                } else {
                    print("⚠️ No historical statistics returned")
                }
                dayTemperatureStatistics = stats
            }

            // Climate stats — cached until end of day
            if let cached = cacheService.retrieve(forKey: "climate_\(locationKey)", as: [MonthlyClimateStats].self) {
                print("💾 Using cached climate stats")
                climateStats = cached
            } else {
                print("🌐 Fetching climate stats...")
                let climate = await weatherService.fetchClimateStats(for: location)
                print("✅ Got \(climate.count) months of climate data")
                if !climate.isEmpty {
                    cacheService.cache(climate, forKey: "climate_\(locationKey)", duration: CacheService.CacheDuration.untilEndOfDay)
                }
                climateStats = climate
            }
            
            lastUpdated = Date()
        } catch {
            print("❌ Weather fetch error: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error description: \(error.localizedDescription)")
            errorMessage = "Failed to load weather data: \(error.localizedDescription)"
        }
        
        isLoading = false
        print("🏁 Weather fetch complete. Loading: \(isLoading)")
    }
    
    func refreshWeatherData() async {
        print("🔄 Refreshing weather data...")
        if let location = currentLocation {
            await fetchWeatherData(for: location)
        }
        await fetchSavedLocationsWeather()
    }
    
    func fetchSavedLocationsWeather() async {
        print("📍 Fetching weather for \(savedLocations.count) saved locations...")
        for location in savedLocations {
            let locationKey = "\(location.latitude),\(location.longitude)"
            
            // Try cache first
            if let cached = cacheService.retrieve(forKey: "current_\(locationKey)", as: CurrentWeather.self) {
                print("💾 Using cached weather for \(location.name)")
                savedLocationsWeather[location.id] = cached
            }
            
            // Fetch fresh data
            do {
                print("🌐 Fetching weather for \(location.name)...")
                let weather = try await weatherService.fetchCurrentWeather(for: location)
                print("✅ Got weather for \(location.name): \(weather.temperature)°")
                savedLocationsWeather[location.id] = weather
                cacheService.cache(weather, forKey: "current_\(locationKey)", duration: CacheService.CacheDuration.currentWeather)
            } catch {
                print("❌ Failed to fetch weather for \(location.name): \(error)")
            }
        }
    }
    
    // MARK: - Saved Locations Management
    
    func loadSavedLocations() {
        savedLocations = storageService.loadSavedLocations()
        print("📂 Loaded \(savedLocations.count) saved locations")
    }
    
    func addLocation(_ location: WeatherLocation) {
        guard savedLocations.count < 3 else { return }
        print("➕ Adding location: \(location.name)")
        savedLocations.append(location)
        storageService.saveSavedLocations(savedLocations)

        Task {
            await fetchWeatherForLocation(location)
            // Prefetch climate/historical data immediately for the new location
            ClimateDataPrefetchService.shared.prefetch(for: location)
        }
    }
    
    func fetchWeatherForLocation(_ location: WeatherLocation) async {
        print("🌤️ Fetching weather for new location: \(location.name)")
        let locationKey = "\(location.latitude),\(location.longitude)"
        
        do {
            let weather = try await weatherService.fetchCurrentWeather(for: location)
            print("✅ Got weather for \(location.name): \(weather.temperature)°")
            savedLocationsWeather[location.id] = weather
            cacheService.cache(weather, forKey: "current_\(locationKey)", duration: CacheService.CacheDuration.currentWeather)
        } catch {
            print("❌ Failed to fetch weather for \(location.name): \(error)")
        }
    }
    
    func removeLocation(_ location: WeatherLocation) {
        print("➖ Removing location: \(location.name)")
        savedLocations.removeAll { $0.id == location.id }
        savedLocationsWeather.removeValue(forKey: location.id)
        storageService.saveSavedLocations(savedLocations)
    }
    
    func reorderLocations(from source: IndexSet, to destination: Int) {
        // Convert IndexSet to array of items to move
        let itemsToMove = source.sorted().map { savedLocations[$0] }
        
        // Remove items from original positions (in reverse order to maintain indices)
        for index in source.sorted().reversed() {
            savedLocations.remove(at: index)
        }
        
        // Calculate adjusted destination
        let adjustedDestination = destination > (source.first ?? 0) ? destination - source.count : destination
        
        // Insert at new position
        savedLocations.insert(contentsOf: itemsToMove, at: adjustedDestination)
        
        storageService.saveSavedLocations(savedLocations)
    }
    
    func canAddMoreLocations() -> Bool {
        return savedLocations.count < 3
    }
}

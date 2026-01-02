//
//  WeatherViewModel.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation
import CoreLocation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentLocation: WeatherLocation?
    @Published var savedLocations: [WeatherLocation] = []
    @Published var currentWeather: CurrentWeather?
    @Published var hourlyForecast: [HourlyForecast] = []
    @Published var dailyForecast: [DailyForecast] = []
    @Published var savedLocationsWeather: [UUID: CurrentWeather] = [:]
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    // MARK: - Services
    
    private let weatherService = WeatherService()
    private let locationService = LocationService()
    private let cacheService = CacheService.shared
    private let storageService = StorageService.shared
    
    // MARK: - Initialization
    
    init() {
        loadSavedLocations()
        Task {
            await setupLocation()
            await fetchSavedLocationsWeather()
        }
    }
    
    // MARK: - Location Setup
    
    func setupLocation() async {
        print("🔍 Starting location setup...")
        locationService.requestLocationPermission()
        
        // Wait a moment for permission
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        print("📍 Location authorization status: \(locationService.authorizationStatus.rawValue)")
        
        if locationService.authorizationStatus == .authorizedWhenInUse ||
           locationService.authorizationStatus == .authorizedAlways {
            locationService.requestLocation()
            
            // Wait for location
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            if let location = locationService.currentLocation {
                print("✅ Got location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                await updateCurrentLocation(from: location)
            } else {
                print("⚠️ No location received, using default (San Francisco)")
                // Fallback to a default location for testing
                let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
                await updateCurrentLocation(from: defaultLocation)
            }
        } else {
            print("⚠️ Location permission not granted, using default location")
            errorMessage = "Location permission denied. Using default location."
            // Use default location
            let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
            await updateCurrentLocation(from: defaultLocation)
        }
    }
    
    func updateCurrentLocation(from clLocation: CLLocation) async {
        print("📍 Updating current location...")
        let location = WeatherLocation(
            name: "Current Location",
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
            
            print("🌐 Fetching daily forecast...")
            let daily = try await weatherService.fetchDailyForecast(for: location)
            print("✅ Got \(daily.count) daily forecasts")
            dailyForecast = daily
            cacheService.cache(daily, forKey: "daily_\(locationKey)", duration: CacheService.CacheDuration.dailyForecast)
            
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
        
        // Fetch weather for the new location
        Task {
            await fetchWeatherForLocation(location)
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

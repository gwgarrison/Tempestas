//
//  WeatherViewModel.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentLocation: WeatherLocation?
    @Published var savedLocations: [WeatherLocation] = []
    @Published var currentWeather: CurrentWeather?
    @Published var hourlyForecast: [HourlyForecast] = []
    @Published var dailyForecast: [DailyForecast] = []
    
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
        }
    }
    
    // MARK: - Location Setup
    
    func setupLocation() async {
        locationService.requestLocationPermission()
        
        // Wait a moment for permission
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        if locationService.authorizationStatus == .authorizedWhenInUse ||
           locationService.authorizationStatus == .authorizedAlways {
            locationService.requestLocation()
            
            // Wait for location
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            if let location = locationService.currentLocation {
                await updateCurrentLocation(from: location)
            }
        }
    }
    
    func updateCurrentLocation(from clLocation: CLLocation) async {
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
        isLoading = true
        errorMessage = nil
        
        let locationKey = "\(location.latitude),\(location.longitude)"
        
        // Try cache first
        if let cached = cacheService.retrieve(forKey: "current_\(locationKey)", as: CurrentWeather.self) {
            currentWeather = cached
        }
        
        if let cached = cacheService.retrieve(forKey: "hourly_\(locationKey)", as: [HourlyForecast].self) {
            hourlyForecast = cached
        }
        
        if let cached = cacheService.retrieve(forKey: "daily_\(locationKey)", as: [DailyForecast].self) {
            dailyForecast = cached
        }
        
        // Fetch fresh data
        do {
            let current = try await weatherService.fetchCurrentWeather(for: location)
            currentWeather = current
            cacheService.cache(current, forKey: "current_\(locationKey)", duration: CacheService.CacheDuration.currentWeather)
            
            let hourly = try await weatherService.fetchHourlyForecast(for: location)
            hourlyForecast = hourly
            cacheService.cache(hourly, forKey: "hourly_\(locationKey)", duration: CacheService.CacheDuration.hourlyForecast)
            
            let daily = try await weatherService.fetchDailyForecast(for: location)
            dailyForecast = daily
            cacheService.cache(daily, forKey: "daily_\(locationKey)", duration: CacheService.CacheDuration.dailyForecast)
            
            lastUpdated = Date()
        } catch {
            errorMessage = "Failed to load weather data"
        }
        
        isLoading = false
    }
    
    func refreshWeatherData() async {
        if let location = currentLocation {
            await fetchWeatherData(for: location)
        }
    }
    
    // MARK: - Saved Locations Management
    
    func loadSavedLocations() {
        savedLocations = storageService.loadSavedLocations()
    }
    
    func addLocation(_ location: WeatherLocation) {
        guard savedLocations.count < 3 else { return }
        savedLocations.append(location)
        storageService.saveSavedLocations(savedLocations)
    }
    
    func removeLocation(_ location: WeatherLocation) {
        savedLocations.removeAll { $0.id == location.id }
        storageService.saveSavedLocations(savedLocations)
    }
    
    func reorderLocations(from source: IndexSet, to destination: Int) {
        savedLocations.move(fromOffsets: source, toOffset: destination)
        storageService.saveSavedLocations(savedLocations)
    }
    
    func canAddMoreLocations() -> Bool {
        return savedLocations.count < 3
    }
}

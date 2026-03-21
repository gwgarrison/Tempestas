//
//  ClimateDataPrefetchService.swift
//  Tempestas
//
//  Prefetches historical and climate data for all known locations
//  so the data is cached before the user navigates to it.
//  Requests are staggered to avoid Open-Meteo throttling.
//

import Foundation

@MainActor
class ClimateDataPrefetchService {
    static let shared = ClimateDataPrefetchService()

    private let weatherService = WeatherService()
    private let cacheService = CacheService.shared
    private let storageService = StorageService.shared

    private var prefetchTask: Task<Void, Never>?

    private init() {}

    // MARK: - Public API

    /// Prefetch climate + historical data for every known location, skipping any that are
    /// already cached. Safe to call multiple times — concurrent calls are deduplicated.
    func prefetchAllIfNeeded(currentLocation: WeatherLocation?) {
        // Cancel any existing in-flight prefetch before starting a new one
        prefetchTask?.cancel()
        prefetchTask = Task {
            await runPrefetch(currentLocation: currentLocation)
        }
    }

    /// Prefetch climate + historical data for a single newly-added location immediately.
    func prefetch(for location: WeatherLocation) {
        Task {
            await fetchClimateData(for: location)
        }
    }

    // MARK: - Private

    private func runPrefetch(currentLocation: WeatherLocation?) async {
        var locations: [WeatherLocation] = []
        if let current = currentLocation { locations.append(current) }
        locations.append(contentsOf: storageService.loadSavedLocations())

        for (index, location) in locations.enumerated() {
            guard !Task.isCancelled else { return }

            let locationKey = "\(location.latitude),\(location.longitude)"
            let needsHistorical = cacheService.retrieve(forKey: "historical_\(locationKey)", as: DailyStatistics.self) == nil
            let needsClimate = cacheService.retrieve(forKey: "climate_\(locationKey)", as: [MonthlyClimateStats].self) == nil

            guard needsHistorical || needsClimate else {
                print("⚡️ Climate prefetch: cache hit for \(location.name), skipping")
                continue
            }

            // Stagger requests across locations to avoid throttling
            if index > 0 {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 s between locations
            }

            guard !Task.isCancelled else { return }
            await fetchClimateData(for: location, needsHistorical: needsHistorical, needsClimate: needsClimate)
        }

        print("✅ Climate prefetch complete")
    }

    private func fetchClimateData(
        for location: WeatherLocation,
        needsHistorical: Bool = true,
        needsClimate: Bool = true
    ) async {
        let locationKey = "\(location.latitude),\(location.longitude)"

        if needsHistorical {
            print("⚡️ Climate prefetch: fetching historical for \(location.name)")
            if let stats = await weatherService.fetchHistoricalAverages(for: location) {
                cacheService.cache(stats, forKey: "historical_\(locationKey)", duration: CacheService.CacheDuration.untilEndOfDay)
                print("✅ Climate prefetch: cached historical for \(location.name)")
            }
        }

        if needsClimate {
            // Small delay between the two requests for the same location
            if needsHistorical {
                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 s
            }
            print("⚡️ Climate prefetch: fetching climate for \(location.name)")
            let climate = await weatherService.fetchClimateStats(for: location)
            if !climate.isEmpty {
                cacheService.cache(climate, forKey: "climate_\(locationKey)", duration: CacheService.CacheDuration.untilEndOfDay)
                print("✅ Climate prefetch: cached climate for \(location.name)")
            }
        }
    }
}

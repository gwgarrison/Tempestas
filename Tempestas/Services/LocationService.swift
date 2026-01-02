//
//  LocationService.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation
import CoreLocation
import MapKit
import Combine

enum LocationServiceError: Error {
    case permissionDenied
    case locationUnavailable
    case searchFailed
}

@MainActor
class LocationService: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func searchLocations(query: String) async throws -> [WeatherLocation] {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            
            return response.mapItems.map { mapItem in
                WeatherLocation(
                    name: formatLocationName(mapItem),
                    latitude: mapItem.placemark.coordinate.latitude,
                    longitude: mapItem.placemark.coordinate.longitude,
                    isCurrentLocation: false
                )
            }
        } catch {
            throw LocationServiceError.searchFailed
        }
    }
    
    private func formatLocationName(_ mapItem: MKMapItem) -> String {
        var components: [String] = []
        
        if let locality = mapItem.placemark.locality {
            components.append(locality)
        }
        
        if let administrativeArea = mapItem.placemark.administrativeArea {
            components.append(administrativeArea)
        }
        
        if let country = mapItem.placemark.country, components.isEmpty {
            components.append(country)
        }
        
        return components.joined(separator: ", ")
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            currentLocation = locations.last
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

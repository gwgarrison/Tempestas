//
//  WeatherLocation.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation
import CoreLocation

struct WeatherLocation: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let isCurrentLocation: Bool
    
    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, isCurrentLocation: Bool = false) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isCurrentLocation = isCurrentLocation
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

//
//  WindFormatter.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

extension Double {
    func formatted(windUnit: WindSpeedUnit) -> String {
        let speed = windUnit == .mph ? self : self * 1.60934
        return String(format: "%.0f %@", speed, windUnit.rawValue)
    }
}

extension Int {
    func toCardinalDirection() -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((Double(self) + 22.5) / 45.0) % 8
        return directions[index]
    }
}

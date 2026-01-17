//
//  TemperatureFormatter.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

extension Double {
    func toFahrenheit() -> Double {
        return (self * 9 / 5) + 32
    }
    
    func toCelsius() -> Double {
        return self
    }
    
    func formatted(unit: TemperatureUnit) -> String {
        let temp = unit == .fahrenheit ? toFahrenheit() : self
        return String(format: "%.0f%@", temp, unit.rawValue)
    }
}

extension Int {
    func formatted(unit: TemperatureUnit) -> String {
        return Double(self).formatted(unit: unit)
    }
}

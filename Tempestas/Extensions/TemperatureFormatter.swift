//
//  TemperatureFormatter.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

extension Double {
    func toFahrenheit() -> Double {
        return self
    }
    
    func toCelsius() -> Double {
        return (self - 32) * 5 / 9
    }
    
    func formatted(unit: TemperatureUnit) -> String {
        let temp = unit == .fahrenheit ? self : toCelsius()
        return String(format: "%.0f%@", temp, unit.rawValue)
    }
}

extension Int {
    func formatted(unit: TemperatureUnit) -> String {
        return Double(self).formatted(unit: unit)
    }
}

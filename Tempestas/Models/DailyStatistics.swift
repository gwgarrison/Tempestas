//
//  DailyStatistics.swift
//  Tempestas
//
//  Created by Gary Garrison on 1/16/26.
//

import Foundation

struct DailyStatistics: Codable {
    let averageHighTemperature: Measurement<UnitTemperature>
    let averageLowTemperature: Measurement<UnitTemperature>
    let allTimeHigh: Measurement<UnitTemperature>
    let allTimeLow: Measurement<UnitTemperature>
}

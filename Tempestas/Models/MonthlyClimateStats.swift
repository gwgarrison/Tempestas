//
//  MonthlyClimateStats.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

struct MonthlyClimateStats: Identifiable {
    var id: Int { month }
    let month: Int // 1-12
    let monthName: String
    let averageHighTemperature: Double // Celsius
    let averageLowTemperature: Double // Celsius
    let averagePrecipitation: Double // mm
}

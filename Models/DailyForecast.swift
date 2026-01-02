//
//  DailyForecast.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

struct DailyForecast: Identifiable, Codable {
    let id: UUID
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let condition: String
    let conditionCode: String
    let precipitationChance: Int
    
    init(id: UUID = UUID(), date: Date, highTemp: Double, lowTemp: Double, condition: String, conditionCode: String, precipitationChance: Int) {
        self.id = id
        self.date = date
        self.highTemp = highTemp
        self.lowTemp = lowTemp
        self.condition = condition
        self.conditionCode = conditionCode
        self.precipitationChance = precipitationChance
    }
}

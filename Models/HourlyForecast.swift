//
//  HourlyForecast.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

struct HourlyForecast: Identifiable, Codable {
    let id: UUID
    let time: Date
    let temperature: Double
    let condition: String
    let conditionCode: String
    let precipitationChance: Int
    
    init(id: UUID = UUID(), time: Date, temperature: Double, condition: String, conditionCode: String, precipitationChance: Int) {
        self.id = id
        self.time = time
        self.temperature = temperature
        self.condition = condition
        self.conditionCode = conditionCode
        self.precipitationChance = precipitationChance
    }
}

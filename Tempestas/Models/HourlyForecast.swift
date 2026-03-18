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
    let windSpeed: Double   // km/h
    let uvIndex: Int

    init(id: UUID = UUID(), time: Date, temperature: Double, condition: String, conditionCode: String, precipitationChance: Int, windSpeed: Double = 0, uvIndex: Int = 0) {
        self.id = id
        self.time = time
        self.temperature = temperature
        self.condition = condition
        self.conditionCode = conditionCode
        self.precipitationChance = precipitationChance
        self.windSpeed = windSpeed
        self.uvIndex = uvIndex
    }

    // Backward-compatible decoding so cached entries without new fields still load
    enum CodingKeys: String, CodingKey {
        case id, time, temperature, condition, conditionCode, precipitationChance, windSpeed, uvIndex
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        time = try c.decode(Date.self, forKey: .time)
        temperature = try c.decode(Double.self, forKey: .temperature)
        condition = try c.decode(String.self, forKey: .condition)
        conditionCode = try c.decode(String.self, forKey: .conditionCode)
        precipitationChance = try c.decode(Int.self, forKey: .precipitationChance)
        windSpeed = try c.decodeIfPresent(Double.self, forKey: .windSpeed) ?? 0
        uvIndex = try c.decodeIfPresent(Int.self, forKey: .uvIndex) ?? 0
    }
}

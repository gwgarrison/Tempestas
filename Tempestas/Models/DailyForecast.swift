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
    let moonPhase: String        // e.g. "Full Moon"
    let moonPhaseSymbol: String  // SF Symbol name

    init(id: UUID = UUID(), date: Date, highTemp: Double, lowTemp: Double, condition: String, conditionCode: String, precipitationChance: Int, moonPhase: String = "", moonPhaseSymbol: String = "moon.fill") {
        self.id = id
        self.date = date
        self.highTemp = highTemp
        self.lowTemp = lowTemp
        self.condition = condition
        self.conditionCode = conditionCode
        self.precipitationChance = precipitationChance
        self.moonPhase = moonPhase
        self.moonPhaseSymbol = moonPhaseSymbol
    }

    // Backward-compatible decoding so cached entries without new fields still load
    enum CodingKeys: String, CodingKey {
        case id, date, highTemp, lowTemp, condition, conditionCode, precipitationChance, moonPhase, moonPhaseSymbol
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        date = try c.decode(Date.self, forKey: .date)
        highTemp = try c.decode(Double.self, forKey: .highTemp)
        lowTemp = try c.decode(Double.self, forKey: .lowTemp)
        condition = try c.decode(String.self, forKey: .condition)
        conditionCode = try c.decode(String.self, forKey: .conditionCode)
        precipitationChance = try c.decode(Int.self, forKey: .precipitationChance)
        moonPhase = try c.decodeIfPresent(String.self, forKey: .moonPhase) ?? ""
        moonPhaseSymbol = try c.decodeIfPresent(String.self, forKey: .moonPhaseSymbol) ?? "moon.fill"
    }
}

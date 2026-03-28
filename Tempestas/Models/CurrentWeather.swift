//
//  CurrentWeather.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

struct CurrentWeather: Codable {
    let temperature: Double
    let feelsLike: Double
    let condition: String
    let conditionCode: String
    let highTemp: Double
    let lowTemp: Double
    let humidity: Int
    let windSpeed: Double
    let windDirection: Int
    let uvIndex: Int
    let sunrise: Date
    let sunset: Date
    let lastUpdated: Date
    var airQualityIndex: Int? = nil
    var airQualityCategory: String? = nil
}

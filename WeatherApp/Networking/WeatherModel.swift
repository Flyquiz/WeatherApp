//
//  Model.swift
//  WeatherApp
//
//  Created by Иван Захаров on 28.09.2023.
//

import UIKit

struct Weather: Decodable {
    let location: Location
    let current: Current
}

struct Location: Decodable {
    let name: String
}

struct Current: Decodable {
    let temp: Double
    let windSpd: Double
    let windDegr: Double
    let windDir: String
    let pressureInch: Double
    let condition: Condition
    
    enum CodingKeys: String, CodingKey {
        case temp = "temp_c"
        case windSpd = "wind_kph"
        case windDegr = "wind_degree"
        case windDir = "wind_dir"
        case pressureInch = "pressure_in"
        case condition
    }
}

struct Condition: Decodable {
    let text: String
}

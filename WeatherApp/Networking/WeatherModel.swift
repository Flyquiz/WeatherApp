//
//  Model.swift
//  WeatherApp
//
//  Created by Иван Захаров on 28.09.2023.
//

import UIKit

//TODO: Возможно придется делать новую модель погоды и инициализировать её из старой модели
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


struct City {
    let name: String
    let weather: Weather
}

final class CitiesStore {
    
    static let shared = CitiesStore()
    
    public var cities: [City] = []
    
    private init() {}
    
    public func addCity(name city: String, weather: Weather) {
        let newCity = City(name: city, weather: weather)
        cities.append(newCity)
    }
}

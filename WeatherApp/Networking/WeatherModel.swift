//
//  Model.swift
//  WeatherApp
//
//  Created by Иван Захаров on 28.09.2023.
//

import UIKit

//TODO: Возможно придется делать новую модель погоды и инициализировать её из старой модели
struct Weather: Codable {
    let location: Location
    let current: Current
}

struct Location: Codable {
    let name: String
}

struct Current: Codable {
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

struct Condition: Codable {
    let text: String
}


struct City: Codable {
    let name: String
    let weather: Weather
}

final class CitiesStore {
    
    static let shared = CitiesStore()
    
    private let userDefaults = UserDefaults.standard
    
    public var cities: [City] = [] {
        didSet {
            do {
                let data = try JSONEncoder().encode(cities)
                userDefaults.setValue(data, forKey: "cities")
            } catch {
                print("UserDefaults encoding error: \(error)")
            }
        }
    }
    
    
    private init() {
        guard let data = userDefaults.data(forKey: "cities") else { return }
        do {
            cities = try JSONDecoder().decode([City].self, from: data)
        } catch {
            print("UserDefaults decoding error: \(error)")
        }
    }
    
    
    public func addCity(name city: String, weather: Weather) {
        let newCity = City(name: city, weather: weather)
        cities.append(newCity)
    }
}

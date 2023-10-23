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
    
    private let networkManager = NetworkManager.shared
    
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
//        updateWeathers()
    }
    
    
    public func addCity(name city: String, weather: Weather) {
        let newCity = City(name: city, weather: weather)
        cities.append(newCity)
    }
    
    //TODO: Отправка ошибки в CitiesListVC
    public func updateWeathers() {
        guard let data = userDefaults.data(forKey: "cities") else { return }
        
        var archiveCites: [City] = []
        var updatedCities: [City] = []
        
        do {
            archiveCites = try JSONDecoder().decode([City].self, from: data)
        } catch {
            print("UserDefaults decoding error during update: \(error)")
        }
        
        let dispatchGroup = DispatchGroup()
        
        for city in archiveCites {
            dispatchGroup.enter()
            networkManager.fetchWeather(city.name) { result in
                switch result {
                case .success(let weather):
                    let city = City(name: weather.location.name, weather: weather)
                    updatedCities.append(city)
                case .failure(_):
                    print("Error update for: \(city)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if updatedCities.count == archiveCites.count {
                self.cities = sortCities()
                print("success update")
            } else {
                self.cities = archiveCites
                print("Can't update cities")
            }
        }
        
        func sortCities() -> [City] {
            var tempArray: [City] = []
            for archC in archiveCites {
                for updC in updatedCities {
                    if updC.name == archC.name {
                        tempArray.append(updC)
                        continue
                    }
                }
            }
            return tempArray
        }
    }
    
    public func deleteCity(city: City) {
        
    }
}


//private init() {
//    guard let data = userDefaults.data(forKey: "cities") else { return }
//
//    var updatedCities: [City] = []
//    var archiveCities: [City] = []
//
//    let dispatchGroup = DispatchGroup()
//
//    do {
//        archiveCities = try JSONDecoder().decode([City].self, from: data)
//    } catch {
//        print("UserDefaults decoding error: \(error)")
//    }
//
//    for city in archiveCities {
//        dispatchGroup.enter()
//        networkManager.fetchWeather(city.name) { result in
//            switch result {
//            case .success(let weather):
//                let city = City(name: weather.location.name, weather: weather)
//                updatedCities.append(city)
//                print("Added: \(city)")
//            case .failure(_):
//                print("Error update for: \(city)")
//                break
//            }
//            dispatchGroup.leave()
//        }
//    }
//    dispatchGroup.notify(queue: .main) { [weak self] in
//        if updatedCities.count == archiveCities.count {
//            self?.cities = updatedCities
//            print("Success update")
//        } else {
//            self?.cities = archiveCities
//            print("Failure update")
//        }
//    }
//}
//
//
//public func addCity(name: String, weather: Weather) {
//    let newCity = City(name: name, weather: weather)
//    cities.append(newCity)
//}
//
//public func updateWeathers() {
//
//}
//}
//
//
//
//private init() {
//    guard let data = userDefaults.data(forKey: "cities") else { return }
//    do {
//        cities = try JSONDecoder().decode([City].self, from: data)
//    } catch {
//        print("UserDefaults decoding error: \(error)")
//    }
//}
//

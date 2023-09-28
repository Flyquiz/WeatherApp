//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Иван Захаров on 28.09.2023.
//

import UIKit

final class NetworkManager {
    
    private let apiKey = "686db746adf5403590d133639232609"
    
    static let shared = NetworkManager()
    private init() {}
    
    
}


//MARK: Links and Errors
extension NetworkManager {
    
    enum Links {
        case baseURL
        case current
        
        var url: URL {
            switch self {
            case .baseURL:
                return URL(string: "http://api.weatherapi.com/v1")!
                //TODO: В запросе (url) обязателен город через параметр q=
            case .current:
                return URL(string: "http://api.weatherapi.com/v1/current.json?")!
            }
        }
    }
    
    enum NetworkError: Error {
        case decodingError
        case noData
        
        var title: String {
            switch self {
            case .decodingError:
                return "Can't decode data"
            case .noData:
                return "Can't get data"
            }
        }
    }
}

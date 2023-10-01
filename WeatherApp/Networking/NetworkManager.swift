//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Иван Захаров on 28.09.2023.
//

import UIKit

final class NetworkManager {
    
    private let apiKey = "686db746adf5403590d133639232609"
    private let q = "q=peterburg"
    
    static let shared = NetworkManager()
    private init() {}
    
    public func fetchWeather(completion: @escaping (Result<Weather, NetworkError>) -> ()) {
        let url = URL(string: Links.current.url.absoluteString + "?" + q)!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "key")
                
        //TODO: timeout interval for apiKey
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data, let response = response as? HTTPURLResponse else { return }
            print(response.statusCode)
            switch response.statusCode {
            case 200...299:
                
                let decoder = JSONDecoder()
                do {
                    let weather = try decoder.decode(Weather.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(weather))
                    }
                } catch {
                    sendError(error: .decodingError)
                }
                //TODO: Errors
            case 400:
                sendError(error: .badRequest)
            case 401:
                sendError(error: .authorizationError)
            case 404:
                sendError(error: .notFound)
            default:
                return
            }
        }.resume()
        
        func sendError(error: NetworkError) {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}



//MARK: Links and Errors
extension NetworkManager {
    
    enum Links {
        case baseURL
        case current
        
        var url: URL {
            switch self {
            case .baseURL:
                return URL(string: "https://api.weatherapi.com/v1")!
            case .current:
                return URL(string: "https://api.weatherapi.com/v1/current.json")!
            }
        }
    }
    
}


enum NetworkError: Error {
    
    case badRequest
    case authorizationError
    case notFound
    case decodingError
    
    var title: String {
        switch self {
        case .badRequest:
            return "400: Can't get data, bad request"
        case .authorizationError:
            return "401: Wrong authorization key for API"
        case .notFound:
            return "404: Can't get data, not found"
        case .decodingError:
            return "Can't decode data"
        }
    }
}

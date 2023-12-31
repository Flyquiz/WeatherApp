//
//  ViewController.swift
//  WeatherApp
//
//  Created by Иван Захаров on 26.09.2023.
//

import UIKit

final class WeatherViewController: UIViewController {
    
    private let networkManager = NetworkManager.shared
    
    //MARK: UIElements
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "City - "
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Condition - "
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Temperature - "
        return label
    }()
    
    private let windMainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Wind:"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let windSpdLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Speed - "
        return label
    }()
    
    private let windDirLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Direction - "
        return label
    }()
    
    private let pressureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pressure - "
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        getWeather()
    }
    
    
    //MARK: Methods
    private func setupLayout() {
        view.backgroundColor = .systemGray6
        
        [cityLabel, 
         conditionLabel,
         tempLabel,
         windMainLabel,
         windSpdLabel,
         windDirLabel,
         pressureLabel,
         activityIndicator].forEach { view.addSubview($0) }
        
        let verticalInset: CGFloat = 10
        let leadingInset: CGFloat = 20
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            conditionLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: verticalInset),
            conditionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingInset),
            
            tempLabel.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: verticalInset),
            tempLabel.leadingAnchor.constraint(equalTo: conditionLabel.leadingAnchor),
            
            pressureLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: verticalInset),
            pressureLabel.leadingAnchor.constraint(equalTo: conditionLabel.leadingAnchor),
            
            
            windMainLabel.topAnchor.constraint(equalTo: pressureLabel.bottomAnchor, constant: verticalInset * 2),
            windMainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            windSpdLabel.topAnchor.constraint(equalTo: windMainLabel.bottomAnchor, constant: verticalInset),
            windSpdLabel.leadingAnchor.constraint(equalTo: conditionLabel.leadingAnchor),
            
            windDirLabel.topAnchor.constraint(equalTo: windSpdLabel.bottomAnchor, constant: verticalInset),
            windDirLabel.leadingAnchor.constraint(equalTo: conditionLabel.leadingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fillToVC(weather: Weather) {
        activityIndicator.removeFromSuperview()
        cityLabel.text! += weather.location.name
        conditionLabel.text! += weather.current.condition.text
        tempLabel.text! += "\(weather.current.temp) C"
        pressureLabel.text! += "\(weather.current.pressureInch) inch"
        windSpdLabel.text! += "\(weather.current.windSpd) kph"
        windDirLabel.text! += "\(weather.current.windDegr) \(weather.current.windDir)"
    }
    
    private func showAlert(error: NetworkError) {
        let alertAction = UIAlertAction(title: "Try again",
                                        style: .destructive) { _ in 
            self.getWeather()
        }
        let alert = UIAlertController(title: "Error",
                                      message: error.title,
                                      preferredStyle: .alert)
            alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    //MARK: Networking
    private func getWeather() {
        networkManager.fetchWeather { [weak self] result in
            switch result {
            case .success(let weather):
                self?.fillToVC(weather: weather)
            case .failure(let error):
                self?.showAlert(error: error)
            }
        }
    }
}

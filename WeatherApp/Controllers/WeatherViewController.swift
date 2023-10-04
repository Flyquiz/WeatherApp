//
//  ViewController.swift
//  WeatherApp
//
//  Created by Иван Захаров on 26.09.2023.
//

import UIKit
import CoreLocation

final class WeatherViewController: UIViewController {
    
    //TODO: Temporary
    private let currentCity = "Peterburg"
    private var isGettingDataFromGeo = false
    
    private let networkManager = NetworkManager.shared
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.requestLocation()
        return manager
    }()
    
    private lazy var currentLocation = CLLocation()
    
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
    
    private lazy var geoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonImage = UIImage(systemName: "location.circle",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.tintColor = .black
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(geoButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var citiesListButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonImage = UIImage(systemName: "list.bullet",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.tintColor = .black
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(citiesListAction), for: .touchUpInside)
        return button
    }()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        setupLayout()
        getWeather(from: currentCity)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
//        if currentCity.isEmpty {
//            geoButtonAction()
//        } else {
//            getWeather(from: currentCity)
//        }
//        
//        if self.isBeingPresented {
//            view.backgroundColor = .systemPink
//        }
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
         activityIndicator,
         geoButton,
         citiesListButton].forEach { view.addSubview($0) }
        
        let verticalInset: CGFloat = 10
        let leadingInset: CGFloat = 20
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            conditionLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: verticalInset * 2),
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
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            citiesListButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            citiesListButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingInset),
            
            geoButton.centerYAnchor.constraint(equalTo: citiesListButton.centerYAnchor),
            geoButton.leadingAnchor.constraint(equalTo: citiesListButton.trailingAnchor, constant: 20)
        ])
    }
    
    private func fillToVC(weather: Weather) {
        cityLabel.text! += weather.location.name
        conditionLabel.text! += weather.current.condition.text
        tempLabel.text! += "\(weather.current.temp) C"
        pressureLabel.text! += "\(weather.current.pressureInch) inch"
        windSpdLabel.text! += "\(weather.current.windSpd) kph"
        windDirLabel.text! += "\(weather.current.windDegr) \(weather.current.windDir)"
        
        //TODO: activityIndicator
        activityIndicator.stopAnimating()
        
        if isGettingDataFromGeo {
            geoButton.tintColor = .systemBlue
        } else {
            geoButton.tintColor = .black
        }
    }
    
    private func clearVC() {
        cityLabel.text! = "City - "
        conditionLabel.text! = "Condition - "
        tempLabel.text! = "Temperature - "
        pressureLabel.text! = "Pressure - "
        windSpdLabel.text! = "Speed - "
        windDirLabel.text! = "Direction - "
    }
    
    //MARK: Alert methods
    private func showNetworkAlert(error: NetworkError) {
        let alertAction = UIAlertAction(title: "Try again",
                                        style: .default) { _ in
            self.getWeather(from: self.currentCity)
        }
        let alert = UIAlertController(title: "Error",
                                      message: error.title,
                                      preferredStyle: .alert)
            alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    private func showLocationAlert() {
        let alertAction = UIAlertAction(title: "OK", style: .default)
        let alert = UIAlertController(title: "Can't get location", message: "Allow access to geolocation in iPhone settings", preferredStyle: .alert)
            alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    //MARK: Networking
    private func getWeather(from location: String) {
//        activityIndicator.startAnimating()
        networkManager.fetchWeather(location) { [weak self] result in
            switch result {
            case .success(let weather):
                self?.clearVC()
                self?.fillToVC(weather: weather)
            case .failure(let error):
                self?.showNetworkAlert(error: error)
            }
        }
    }
    
    //MARK: Actions
    @objc private func geoButtonAction() {
        if locationManager.authorizationStatus != .denied {
            locationManager.requestLocation()
        } else {
            showLocationAlert()
            //            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @objc private func citiesListAction() {
        navigationController?.pushViewController(CitiesListController(), animated: true)
    }
}
              

              

//MARK: Location
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location)
            currentLocation = location
            
            let latitude = location.coordinate.latitude as Double
            let longitude = location.coordinate.longitude as Double
            let strLocation = "\(latitude) \(longitude)"
            getWeather(from: strLocation)
            isGettingDataFromGeo = true
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    //TODO: Did't work requestLocation when Auth did change
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if UIApplication.shared.applicationState == .active && manager.authorizationStatus != .denied {
            manager.requestLocation()
        }
        if manager.authorizationStatus == .denied {
            showLocationAlert()
        }
    }
}

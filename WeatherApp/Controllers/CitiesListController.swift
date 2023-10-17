//
//  CitiesListController.swift
//  WeatherApp
//
//  Created by Иван Захаров on 02.10.2023.
//

import UIKit
//TODO: Данные не обновляются
final class CitiesListController: UIViewController {
    
    private var citiesStore = CitiesStore.shared
    
    private var geoWeather: Weather? = nil
    
    //MARK: UIElements
    private lazy var citiesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CityCollectionViewCell.self, forCellWithReuseIdentifier: CityCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = view.backgroundColor
        return collectionView
    }()
    
    private lazy var citySearchController: UISearchController = {
        let searchController = UISearchController()
        searchController.delegate = self
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = citySearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        title = "Weather"
        setupLayout()
        let previousVC = WeatherViewController()
        previousVC.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        citiesCollectionView.reloadData()
    }
    
    //MARK: Methods
    private func setupLayout() {
        view.backgroundColor = .systemGray6
        view.addSubview(citiesCollectionView)
        
        NSLayoutConstraint.activate([
            citiesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            citiesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            citiesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            citiesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}



//MARK: collectionView: DataSource
extension CitiesListController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return citiesStore.cities.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityCollectionViewCell.identifier, for: indexPath) as! CityCollectionViewCell
        cell.contentView.layer.cornerRadius = cell.bounds.height / 5
        
        switch indexPath.section {
        case 0:
            if let weather = geoWeather {
                let currentCity = City(name: weather.location.name, weather: weather)
                cell.setupCell(city: currentCity)
                return cell
            } else {
                cell.showError()
                return cell
            }
        default:
            cell.setupCell(city: citiesStore.cities[indexPath.item])
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as! HeaderCollectionReusableView        
        switch indexPath.section {
        case 0:
            header.headerLabel.text = "Current location"
            return header
        case 1:
            header.headerLabel.text = "Favorites"
            return header
        default:
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        //TODO: Расчет высоты хедера
        return CGSize(width: view.bounds.width, height: view.bounds.width / 20)
    }
}



//MARK: collectionView: DelegateFlowLayout
extension CitiesListController: UICollectionViewDelegateFlowLayout {
    
    private var inset: CGFloat { return 20 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - inset * 2
        let height = (collectionView.bounds.height - inset * 6) / 5
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return inset
    }
}


//MARK: Search delegates
extension CitiesListController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        if text.checkEmptiness {
            let vc = WeatherViewController()
            vc.currentCity = text
            vc.callBack = {
                self.citiesStore.cities = CitiesStore.shared.cities
                self.citySearchController.isActive = false
                self.citiesCollectionView.reloadData()
            }
            present(vc, animated: true)
        } else {
            searchBar.text = ""
            return
        }
    }
    //TODO: Стоит убрать
    func willDismissSearchController(_ searchController: UISearchController) {
        self.citiesCollectionView.reloadData()
    }
}



//MARK: VCDelegate
extension CitiesListController: WeatherSenderDelegate {
    func getGeoWeatherFromVC(weather: Weather?) {
        geoWeather = weather
    }
}

//
//  CitiesListController.swift
//  WeatherApp
//
//  Created by Иван Захаров on 02.10.2023.
//

import UIKit
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
        collectionView.register(FavoriteCityCollectionViewCell.self, forCellWithReuseIdentifier: FavoriteCityCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        
        collectionView.backgroundColor = view.backgroundColor
        return collectionView
    }()
    
    private lazy var citySearchController: UISearchController = {
        let searchController = UISearchController()
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Add city"
        return searchController
    }()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let previousVC = WeatherViewController()
        previousVC.delegate = self
        setupNavigationBar()
        setupLayout()
        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        citiesCollectionView.reloadData()
    }
    
    //MARK: Methods
    private func setupNavigationBar() {
        navigationItem.searchController = citySearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItem = editButtonItem
        title = "Weather"
    }
    
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
    
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureAction))
        citiesCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
//        citiesCollectionView.allowsMultipleSelection = editing
        citiesCollectionView.indexPathsForVisibleItems.forEach { indexPath in
            guard indexPath.section != 0 else { return }
            let cell = citiesCollectionView.cellForItem(at: indexPath) as! FavoriteCityCollectionViewCell
                cell.isEditing = editing
        }
    }
    
    private func deleteCell(at indexPath: IndexPath) {
        citiesCollectionView.performBatchUpdates {
            citiesCollectionView.deleteItems(at: [indexPath])
            citiesStore.cities.remove(at: indexPath.item)
        } completion: { _ in 
            self.citiesCollectionView.reloadData()
        }
    }
    
    //MARK: Actions
    @objc private func longPressGestureAction(_ gesture: UILongPressGestureRecognizer) {
        let gestureLocation = gesture.location(in: citiesCollectionView)
        switch gesture.state {
        case .began:
            guard let targetIndexPath = citiesCollectionView.indexPathForItem(at: gestureLocation) else { return }
            citiesCollectionView.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            citiesCollectionView.updateInteractiveMovementTargetPosition(gestureLocation)
        case .ended:
            citiesCollectionView.endInteractiveMovement()
        default:
            citiesCollectionView.cancelInteractiveMovement()
        }
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
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityCollectionViewCell.identifier, for: indexPath) as! CityCollectionViewCell
            cell.contentView.layer.cornerRadius = cell.bounds.height / 5
            if let weather = geoWeather {
                let currentCity = City(name: weather.location.name, weather: weather)
                cell.setupCell(city: currentCity)
                return cell
            } else {
                cell.showError()
                return cell
            }
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCityCollectionViewCell.identifier, for: indexPath) as! FavoriteCityCollectionViewCell
            cell.contentView.layer.cornerRadius = cell.bounds.height / 5
            cell.setupCell(city: citiesStore.cities[indexPath.item])
            cell.isEditing = isEditing
            cell.deleteCallBack = { [weak self] in
                self?.deleteCell(at: indexPath)
            }
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    
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
}



//MARK: collectionView: DelegateFlowLayout
extension CitiesListController: UICollectionViewDelegateFlowLayout {
    
    private var inset: CGFloat { return 20 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        //TODO: Расчет высоты хедера
        return CGSize(width: view.bounds.width, height: view.bounds.width / 20)
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if !isEditing {
//            //detailView
        //        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        default:
            return isEditing
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = citiesStore.cities.remove(at: sourceIndexPath.item)
        citiesStore.cities.insert(item, at: destinationIndexPath.item)
    }
}


//MARK: Search delegates
extension CitiesListController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        if text.checkEmptiness {
            let vc = WeatherViewController()
            vc.getWeather(from: text)
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

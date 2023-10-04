//
//  CitiesListController.swift
//  WeatherApp
//
//  Created by Иван Захаров on 02.10.2023.
//

import UIKit

final class CitiesListController: UIViewController {
    
    //MARK: UIElements
    private lazy var citiesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CityCollectionViewCell.self, forCellWithReuseIdentifier: CityCollectionViewCell.identifier)
        collectionView.backgroundColor = view.backgroundColor
        return collectionView
    }()
    
    private lazy var citySearchController: UISearchController = {
        let searchController = UISearchController()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
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
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityCollectionViewCell.identifier, for: indexPath) as! CityCollectionViewCell
        cell.contentView.layer.cornerRadius = cell.bounds.height / 5
        return cell
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



extension CitiesListController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        if text.checkEmptiness {
            let vc = WeatherViewController()
            vc.currentCity = text
            present(vc, animated: true)
        } else {
            searchBar.text = ""
            return
        }
    }
}

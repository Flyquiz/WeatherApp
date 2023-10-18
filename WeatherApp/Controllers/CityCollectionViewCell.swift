//
//  CitiesCollectionViewCell.swift
//  WeatherApp
//
//  Created by Иван Захаров on 02.10.2023.
//

import UIKit

class CityCollectionViewCell: UICollectionViewCell {
    
    //MARK: UIElements
    fileprivate let cityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "city"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    fileprivate let conditionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "condition"
        return label
    }()
    
    fileprivate let tempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "temp"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Geolocation disabled"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.isHidden = true
        return label
    }()
    
    
    //MARK: Init. and methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    @available(*,unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cityLabel.text = nil
        conditionLabel.text = nil
        tempLabel.text = nil
    }
    
    public func setupCell(city: City) {
        cityLabel.text = city.name
        conditionLabel.text = city.weather.current.condition.text
        tempLabel.text = String(city.weather.current.temp)
    }
    
    public func showError() {
        cityLabel.isHidden = true
        conditionLabel.isHidden = true
        tempLabel.isHidden = true
        errorLabel.isHidden = false
    }
    
    fileprivate func setupLayout() {
        contentView.backgroundColor = .systemGray5
        
        [cityLabel,
         conditionLabel,
         tempLabel,
         errorLabel].forEach {
            contentView.addSubview($0)
        }
        
        let inset: CGFloat = 20
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            
            conditionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            conditionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            
            tempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            tempLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

final class FavoriteCityCollectionViewCell: CityCollectionViewCell {
    
    public var deleteCallBack: (() -> ()) = {}
    
    public var isEditing = false {
        didSet {
            tempLabel.isHidden = isEditing
            deleteButton.isHidden = !isEditing
            moveButton.isHidden = !isEditing
        }
    }
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage =  UIImage(systemName: "trash.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.tintColor = .systemRed
        button.setImage(buttonImage, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return button
    }()
    
    private let moveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage =  UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.tintColor = .systemGray
        button.setImage(buttonImage, for: .normal)
        button.isHidden = true
        return button
    }()
    
    
    override func setupLayout() {
        super.setupLayout()
        
        [deleteButton,moveButton].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.centerYAnchor.constraint(equalTo: tempLabel.centerYAnchor),
            
            moveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moveButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @objc private func deleteAction() {
        deleteCallBack()
    }
}

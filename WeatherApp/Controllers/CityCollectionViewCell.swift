//
//  CitiesCollectionViewCell.swift
//  WeatherApp
//
//  Created by Иван Захаров on 02.10.2023.
//

import UIKit

final class CityCollectionViewCell: UICollectionViewCell {
    
    //MARK: UIElements
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "city"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "condition"
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "temp"
        label.font = .systemFont(ofSize: 40, weight: .bold)
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
    
    private func setupLayout() {
        contentView.backgroundColor = .systemGray5
        
        [cityLabel, conditionLabel, tempLabel].forEach {
            contentView.addSubview($0)
        }
        
        let inset: CGFloat = 20
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            
            conditionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            conditionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            
            tempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            tempLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

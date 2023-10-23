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
        
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: trailingInset),
            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: trailingInset),
            
            conditionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: trailingInset),
            conditionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -trailingInset),
            
            tempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -trailingInset),
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
            switch isEditing {
            case true:
                animateBeforeEditing()
            case false:
                animateAfterEditing()
            }
        }
    }
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage =  UIImage(systemName: "trash.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.tintColor = .systemRed
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return button
    }()
    
    private let moveImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let image =  UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15))
        imageView.tintColor = .systemGray
        imageView.image = image
        return imageView
    }()
    
    private let animateTransitionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setupLayout() {
        super.setupLayout()
        
        contentView.addSubview(animateTransitionView)
        animateTransitionView.addSubview(tempLabel)
        animateTransitionView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            animateTransitionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -trailingInset),
            animateTransitionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            animateTransitionView.heightAnchor.constraint(equalToConstant: tempLabel.intrinsicContentSize.height),
            animateTransitionView.widthAnchor.constraint(equalToConstant: tempLabel.intrinsicContentSize.width)
        ])
    }
    
    private func animateBeforeEditing() {
        contentView.addSubview(moveImage)
        moveImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        moveImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: tempLabel.trailingAnchor, constant: -trailingInset / 2).isActive = true
        deleteButton.centerYAnchor.constraint(equalTo: tempLabel.centerYAnchor).isActive = true
        moveImage.alpha = 0.0
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut) { [self] in
            moveImage.alpha = 1.0
            moveImage.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }
        
        UIView.transition(from: tempLabel, to: deleteButton, duration: duration, options: [.showHideTransitionViews, .curveEaseInOut, .transitionCrossDissolve])
    }
    
    private func animateAfterEditing() {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut) { [self] in
            moveImage.alpha = 0.0
            moveImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        } completion: { [self] _ in
            moveImage.removeFromSuperview()
        }
        
        UIView.transition(from: deleteButton, to: tempLabel, duration: duration, options: [.showHideTransitionViews, .curveEaseInOut, .transitionCrossDissolve])
    }
    
    @objc private func deleteAction() {
        deleteCallBack()
    }
}



extension CityCollectionViewCell {
    ///Trailing inset for constraints
    internal var trailingInset: CGFloat { return 20 }
    ///Time duration for all animations
    internal var duration: Double { return 0.3 }
}

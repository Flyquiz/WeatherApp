//
//  HeaderCollectionReusableView.swift
//  WeatherApp
//
//  Created by Иван Захаров on 05.10.2023.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    
    public let headerLabel: UILabel = {
        let label = UILabel(frame: CGRect())
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(headerLabel)
        headerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        headerLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

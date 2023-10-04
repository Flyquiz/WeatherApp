//
//  Extensions.swift
//  WeatherApp
//
//  Created by Иван Захаров on 04.10.2023.
//

import UIKit

//MARK: Identifier for registration cells
extension UIView {
    static var identifier: String {
        String(describing: self)
    }
}

//MARK: Checking emptiness with spaces
extension String {
    public var checkEmptiness: Bool {
        get {
            guard self.isEmpty != true else { return false }
            
            for char in self {
                guard char == Character(" ") else { return true }
            } 
            return false
        }
    }
}

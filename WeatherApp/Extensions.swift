//
//  Extensions.swift
//  WeatherApp
//
//  Created by Иван Захаров on 04.10.2023.
//

import UIKit

extension UIView {
    
    /// Identifier for registration cells
    static var identifier: String {
        String(describing: self)
    }
}

extension String {
    
    /// Checking emptiness with spaces
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

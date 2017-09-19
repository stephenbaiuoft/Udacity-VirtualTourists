//
//  SwiftHelperExtension.swift
//  VirtualTourist
//
//  Created by stephen on 9/13/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    
}

/**
 
 */
 
extension UIImage {

}

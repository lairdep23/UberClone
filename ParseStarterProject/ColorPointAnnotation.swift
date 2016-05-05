//
//  ColorPointAnnotation.swift
//  UberClone
//
//  Created by Evan on 5/5/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ColorPointAnnotation : MKPointAnnotation {
    
    var pinColor: UIColor
    
    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
}

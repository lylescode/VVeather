//
//  ValueExtension.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

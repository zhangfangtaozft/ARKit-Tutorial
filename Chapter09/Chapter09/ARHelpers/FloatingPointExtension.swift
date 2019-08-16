//
//  FloatingPointExtension.swift
//  Chapter09
//
//  Created by frank.zhang on 2019/8/14.
//  Copyright © 2019 Frank. All rights reserved.
//

import Foundation
extension FloatingPoint{
    var degreeToRadians: Self{return self * .pi / 180}
    var radiansToDegrees: Self{return self * 180 / .pi}
}


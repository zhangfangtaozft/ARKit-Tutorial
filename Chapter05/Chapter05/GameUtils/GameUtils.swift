//
//  GameUtils.swift
//  Chapter05
//
//  Created by frank.zhang on 2019/8/7.
//  Copyright © 2019 Frank. All rights reserved.
//

import Foundation
import CoreGraphics

let DegreesPerRadians = Float(Double.pi/180)
let RadiansPerDegrees = Float(180/Double.pi)

func convertToRadians(angle: Float) -> Float{
    return angle * DegreesPerRadians
}

func convertToRadians(angle: CGFloat) -> CGFloat{
    return CGFloat(CGFloat(angle) * CGFloat(DegreesPerRadians))
}

//MARK； - Convert Radians to Degrees
func convertToDegrees(angle: Float) -> Float{
    return angle * RadiansPerDegrees
}

func convertToDegrees(angle: CGFloat) -> CGFloat{
    return CGFloat(CGFloat(angle) * CGFloat(RadiansPerDegrees))
}


//
//  Random+Extension.swift
//  Chapter05
//
//  Created by frank.zhang on 2019/8/7.
//  Copyright © 2019 Frank. All rights reserved.
//

import Foundation

public extension Double{
    static func random(min: Double, max: Double) -> Double{
        let r64 = Double(arc4random(UInt64.self)) / Double(UINT64_MAX)
        return (r64 * (max - min)) + min
    }
}

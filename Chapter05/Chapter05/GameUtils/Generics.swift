//
//  Generics.swift
//  Chapter05
//
//  Created by frank.zhang on 2019/8/7.
//  Copyright © 2019 Frank. All rights reserved.
//

import Foundation

public func arc4random<T: ExpressibleByIntegerLiteral> (_ type: T.Type) -> T{
    var r: T = 0
    arc4random_buf(&r, Int(MemoryLayout<T>.size))
    return r
}

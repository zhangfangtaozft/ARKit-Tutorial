//
//  RectangularPlane.swift
//  Chapter13
//
//  Created by frank.zhang on 2019/9/9.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import simd
import SceneKit

struct RectangularPlane {
    var center: matrix_float4x4
    
    var width: CGFloat
    var height: CGFloat
    var length: CGFloat { return 0.005 }
    
    init(center: matrix_float4x4, size: CGSize) {
        self.center = center
        self.width = size.width
        self.height = size.height
    }
    
    init(topLeft: matrix_float4x4, topRight: matrix_float4x4, bottomLeft: matrix_float4x4, bottomRight: matrix_float4x4) {
        self.width = CGFloat(simd_distance(topRight.simdPosition, topLeft.simdPosition))
        self.height = CGFloat(simd_distance(topRight.simdPosition, bottomRight.simdPosition))
        
        let c1 = simd_mul(0.5, topLeft + bottomRight)
        let c2 = simd_mul(0.5, topRight + bottomLeft)
        self.center = simd_linear_combination(0.5, c1, 0.5, c2)
    }
}

extension matrix_float4x4 {
    var simdPosition: simd_float3 {
        return simd_float3(position)
    }
    
    var position: SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}


/**
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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

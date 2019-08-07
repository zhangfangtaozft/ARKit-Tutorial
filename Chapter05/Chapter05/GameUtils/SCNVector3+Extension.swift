//
//  SCNVector3+Extension.swift
//  Chapter05
//
//  Created by frank.zhang on 2019/8/7.
//  Copyright © 2019 Frank. All rights reserved.
//

import Foundation
import CoreGraphics
import SceneKit

extension SCNVector3{
    
    /// invert()
    ///
    /// - Returns: SCNVector3
    mutating func invert() -> SCNVector3 {
        return self * -1
    }
    
    
    ///  Calculates vector length based on Pythagoras theorem
    var length:Float {
        get {
            return sqrtf(x*x + y*y + z*z)
        }
        set {
            self = self.unit * newValue
        }
    }
    
    
    /// Calculate Length Squared of Vector,  - Use this to determine Longest/Shortest vector. Much faster than using v.length
    var lengthSquared: Float {
        get{
            return self.x * self.x + self.y * self.y + self.z * self.z
        }
    }
    
    
    /// Returns unit vector (aka Normalized Vector)  - v.length = 1.0
    var unit:SCNVector3{
        get{
            return self / self.length
        }
    }
    
    
    /// Normalizes vector  - v.Length = 1.0
    mutating func normalize(){
        self = self.unit
    }
    
    
    /// Calculates distance to vector
    ///
    /// - Parameter toVector: toVector
    /// - Returns: Float
    func distance(toVector: SCNVector3) -> Float{
        return (self - toVector).length
    }
    
    ///  Calculates dot product to vector
    ///
    /// - Parameter toVector: toVector
    /// - Returns: Float
    func dot(toVector: SCNVector3) -> Float{
        return x * toVector.x + y * toVector.y + z * toVector.z
    }
    
    /// Calculates dot product to vector
    ///
    /// - Parameter toVector: toVector
    /// - Returns: SCNVector3
    func cross(toVector: SCNVector3) -> SCNVector3{
        return  SCNVector3Make(y * toVector.z - z * toVector.y, z * toVector.z - x * toVector.z, x * toVector.y - y * toVector.x)
    }
    
    ///  Get/Set vector angle on XY axis
    var xyAngle: Float{
        get{
            return atan2(self.y, self.x)
        }set{
            let length = self.length
            self.x = cos(newValue) * length
            self.y = sin(newValue) * length
        }
    }
    
    /// Get/Set vector angle on XZ axis
    var xzAngle: Float{
        get{
            return atan2(self.z, self.x)
        }set{
            let length = self.length
            self.x = cos(newValue) * length
            self.z = sin(newValue) * length
        }
    }
    
    /// Get angle between two vectors
    ///
    /// - Parameter toVector: toVector
    /// - Returns: Float
    func angleBetweenVectors(_ toVector: SCNVector3) -> Float{
        //cos(angle) = (A.B)/(|A||B|)
        let cosinAngle = (dot(toVector: toVector) / (length * toVector.length))
        return Float(acos(cosinAngle))
    }
    
    /// up
    var up: SCNVector3{
        get{
            return SCNVector3(0, self.y, 0)
        }
    }
    
    var front: SCNVector3{
        get{
            return SCNVector3(0, 0, self.z)
        }
    }
    
    var right: SCNVector3{
        get{
            return SCNVector3(self.x, 0, 0)
        }
    }
}

//MARK: - SCNVector Operators

/// v1 = v2 + v3
///
/// - Parameters:
///   - left:
///   - right:
/// - Returns:
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3{
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

///  v1 += v2
///
/// - Parameters:
///   - left:
///   - right:
func +=(left: inout SCNVector3, right: SCNVector3){
    left  = left + right
}

///  v1 = v2 - v3
///
/// - Parameters:
///   - left:
///   - right:
/// - Returns:
func -(left: SCNVector3, right: SCNVector3) -> SCNVector3{
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

///  v1 -= v2
///
/// - Parameters:
///   - left:
///   - right:
func -=(left: inout SCNVector3, right: SCNVector3){
    left = left - right
}

///  v1 = v2 * v3
///
/// - Parameters:
///   - left:
///   - right:
/// - Returns:
func *(left: SCNVector3, right: SCNVector3) -> SCNVector3{
    return SCNVector3Make(left.x * right.x, left.y  * right.y, left.z * right.z)
}

///  v1 *= v2
///
/// - Parameters:
///   - left:
///   - right:
func *= (left: inout SCNVector3, right: SCNVector3){
    left = left * right
}

///  v1 = v2 * x
///
/// - Parameters:
///   - left:
///   - right:
/// - Returns:
func *(left: SCNVector3, right: Float) -> SCNVector3{
    return SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

///   v *= x
///
/// - Parameters:
///   - left:
///   - right:
func *=(left: inout SCNVector3, right: Float){
    left = SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

/// v1 = v2 / v3
///
/// - Parameters:
///   - left:
///   - right:
/// - Returns:
func /(left: SCNVector3, right: SCNVector3) -> SCNVector3{
    return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

///  v1 /= v2
///
/// - Parameters:
///   - left:
///   - right:
func /=(left: inout SCNVector3, right: SCNVector3){
    left = SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

///  v1 = v2 / x
///
/// - Parameters:
///   - left:
///   - right:
/// - Returns:
func /(left: SCNVector3, right: Float) -> SCNVector3{
    return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

///  v /= x
///
/// - Parameters:
///   - left:
///   - right:
func /=(left: inout SCNVector3, right: Float){
    left = SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

///  v = -v
///
/// - Returns:
prefix func -(v: SCNVector3) -> SCNVector3{
    return v * -1
}

//
//  BillboardContainer.swift
//  Chapter10
//
//  Created by frank.zhang on 2019/8/19.
//  Copyright © 2019 Frank. All rights reserved.
//

import ARKit
import SceneKit

struct BillboardContainer {
    var billboardAnchor: ARAnchor
    var billboardNode: SCNNode?
    var plane: RectangularPlane
    var hasBillboardNode: Bool {return billboardNode != nil}
    
    init(billboardAnchor: ARAnchor, plane: RectangularPlane) {
        self.billboardAnchor = billboardAnchor
        self.plane = plane
        self.billboardNode = nil
    }
}

//
//  BillboardContainer.swift
//  Chapter11
//
//  Created by frank.zhang on 2019/8/20.
//  Copyright © 2019 Frank. All rights reserved.
//

import ARKit
import SceneKit

struct BillboardContainer {
    var billboardAnchor: ARAnchor
    var billboardNode: SCNNode?
    var videoAnchor: ARAnchor?
    var videoNode: SCNNode?
    var plane: RectangularPlane
    var viewController: BillboardViewController?
    var hasBillboardNode: Bool{return billboardNode != nil}
    var hasVideosNode: Bool {return videoNode != nil}
    
    init(billboardAnchor: ARAnchor, plane: RectangularPlane){
        self.billboardAnchor = billboardAnchor
        self.plane = plane
        self.billboardNode = nil
        self.videoAnchor = nil
        self.videoNode = nil
    }
}



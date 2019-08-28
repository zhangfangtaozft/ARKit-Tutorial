//
//  BillboardContainer.swift
//  Chapter12
//
//  Created by frank.zhang on 2019/8/26.
//  Copyright © 2019 Frank. All rights reserved.
//

import ARKit
import SceneKit

protocol VideoNodeHandler: class {
    func createNode() -> SCNNode?
    func removeNode()
}

protocol VideoPlayerDelegate: class {
    func didStartPlay()
    func didEndPlay()
}

class BillboardContainer {
    var billboardAnchor: ARAnchor
    var billboardNode: SCNNode?
    var videoAnchor: ARAnchor?
    var videoNode: SCNNode?
    var plane: RectangularPlane
    var isFullScreen = false
    var viewController: BillboardViewController?
    
    var hasBillboardNode: Bool { return billboardNode != nil }
    var hasVideoNode: Bool { return videoNode != nil }
    
    weak var videoNodeHandler: VideoNodeHandler?
    weak var videoPlayerDelegate: VideoPlayerDelegate?
    
    init(billboardAnchor: ARAnchor, plane: RectangularPlane) {
        self.billboardAnchor = billboardAnchor
        self.plane = plane
        self.billboardNode = nil
        self.videoAnchor = nil
        self.videoNode = nil
    }
}

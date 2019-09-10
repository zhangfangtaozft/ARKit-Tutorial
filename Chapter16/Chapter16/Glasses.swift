//
//  Glasses.swift
//  Chapter16
//
//  Created by frank.zhang on 2019/9/10.
//  Copyright © 2019 Frank. All rights reserved.
//

import ARKit

class Glasses: SCNNode {
    let occlusionNode: SCNNode
    init(geometry: ARSCNFaceGeometry) {
        geometry.firstMaterial?.colorBufferWriteMask = []
        occlusionNode = SCNNode(geometry: geometry)
        occlusionNode.renderingOrder = -1
        super.init()
        addChildNode(occlusionNode)
        // 1
        guard let url = Bundle.main.url(forResource: "glasses", withExtension: "scn", subdirectory: "Models.scnassets") else {
            fatalError("Missing resource")
        }
        // 2
        let node = SCNReferenceNode(url: url)!
        node.load()
        // 3
        addChildNode(node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    // - Tag: ARFaceAnchor Update
    func update(withFaceAnchor anchor: ARFaceAnchor){
        let faceGeometry = occlusionNode.geometry as! ARSCNFaceGeometry
        faceGeometry.update(from: anchor.geometry)
    }
}

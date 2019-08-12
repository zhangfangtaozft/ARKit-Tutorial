//
//  ViewController.swift
//  Chapter07
//
//  Created by frank.zhang on 2019/8/12.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messageLabel: ARLabel!
    @IBOutlet weak var sessionStateLabel: ARLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabels()
        runSession()
    }
    
    func runSession(){
        let configuation = ARWorldTrackingConfiguration.init()
        configuation.planeDetection = .horizontal
        configuation.isLightEstimationEnabled = true
        sceneView.session.run(configuation)
        #if DEBUG
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
        #endif
        sceneView.delegate = self
    }
    
    func resetLabels(){
        messageLabel.alpha = 1.0
        messageLabel.text = "Move the phone around and allow the app to find a plane. You will see a yellow horizontal plane."
        sessionStateLabel.alpha = 0.0
        sessionStateLabel.text = ""
        
    }
}

extension ViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor){
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor{
                #if DEBUG
                let debugPlaneNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
                node.addChildNode(debugPlaneNode)
                #endif
                self.messageLabel.alpha = 1.0
                self.messageLabel.text = "Tap on the detected horizontal plane to place the portal"
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor){
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, !node.childNodes.isEmpty{
                updatePlaneNode(node.childNodes[0], center: planeAnchor.center, extent: planeAnchor.extent)
            }
        }
    }
}

//
//  ViewController.swift
//  Chapter08
//
//  Created by frank.zhang on 2019/8/13.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController{
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var crosshair: UIView!
    @IBOutlet weak var messageLabel: ARLabel!
    @IBOutlet weak var sessionStateLabel: ARLabel!
    
    private var portalNode: SCNNode? = nil
    private var isPortalPlaced = false
    private var debugPlanes: [SCNNode] = []
    private var viewCenter: CGPoint{
        return view.center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabels()
        runSession()
    }
    
    func runSession(){
      let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: .removeExistingAnchors)
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
    
    func showMessage(_ message: String, label: UILabel, second: Double){
        label.text = message
        label.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + second) {
            if label.text == message{
                label.text = ""
                label.alpha = 0.0
            }
        }
    }
    
    func removeAllNodes(){
        removeDebugPlanes()
        self.portalNode?.removeFromParentNode()
        self.isPortalPlaced = false
    }
    
    func removeDebugPlanes(){
        for debugPlaneNode in self.debugPlanes {
            debugPlaneNode.removeFromParentNode()
        }
        debugPlanes = []
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let hit = sceneView.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first {
            sceneView.session.add(anchor: ARAnchor.init(transform: hit.worldTransform))
        }
    }
    
    func makePortal() -> SCNNode{
        let portal = SCNNode()
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let boxNode = SCNNode(geometry: box)
        portal.addChildNode(boxNode)
        return portal
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, !self.isPortalPlaced{
                #if DEBUG
                let debugPlaneNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
                node.addChildNode(debugPlaneNode)
                #endif
                self.messageLabel.alpha = 1.0
                self.messageLabel.text = """
                Tap on the detected \
                horizontal plane to place the portal
                """
            }
            else if !self.isPortalPlaced {
                self.portalNode = self.makePortal()
                if let portal = self.portalNode{
                    node.addChildNode(portal)
                    self.isPortalPlaced = true
                    self.removeDebugPlanes()
                    self.sceneView.debugOptions = []
                    DispatchQueue.main.async {
                        self.messageLabel.text = ""
                        self.messageLabel.alpha = 0.0
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count > 0, !self.isPortalPlaced{
                updatePlaneNode(node.childNodes[0], center: planeAnchor.center, extent: planeAnchor.extent)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            if let _ = self.sceneView.hitTest(self.viewCenter, types: [.existingPlaneUsingExtent]).first{
                self.crosshair.backgroundColor = UIColor.green
            }else{
                self.crosshair.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let label = self.sessionStateLabel else {return}
        showMessage(error.localizedDescription, label: label, second: 3.0)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        guard let label = self.sessionStateLabel else {return}
        showMessage("Session interrupted", label: label, second: 3.0)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        guard let label = self.sessionStateLabel else {return}
        showMessage("Session resumed", label: label, second: 3.0)
        DispatchQueue.main.async {
            self.removeAllNodes()
            self.resetLabels()
        }
        runSession()
    }
}

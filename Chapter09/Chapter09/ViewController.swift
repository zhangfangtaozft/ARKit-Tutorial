//
//  ViewController.swift
//  Chapter09
//
//  Created by frank.zhang on 2019/8/14.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController{
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var crosshair: UIView!
    @IBOutlet weak var messageLabel: ARLabel!
    @IBOutlet weak var sessionStateLabel: ARLabel!
    
    var portalNode: SCNNode? = nil
    var isPortalPlaced = false
    var debugPlanes: [SCNNode] = []
    var viewCenter: CGPoint{
        return view.center
    }
    let positionY: CGFloat = -0.25
    let positionZ: CGFloat = -surfaceLength * 0.5
    let doorWidth: CGFloat = 1.0
    let doorHeight: CGFloat = 2.4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabels()
        runSession()
    }
    
    func runSession(){
        let configuation = ARWorldTrackingConfiguration()
        configuation.planeDetection = .horizontal
        configuation.isLightEstimationEnabled = true
        sceneView.session.run(configuation, options: [.resetTracking, .removeExistingAnchors])
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
    
    func showmessage(_ message: String, label: UILabel, seconds: Double){
        label.text = message
        label.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if label.text == message{
                label.text = ""
                label.alpha = 0
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
        self.debugPlanes = []
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let hit = sceneView.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first {
            sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
        }
    }
    
    func makePortal() -> SCNNode {
        let portal = SCNNode()
        
        let floorNode = makeFloorNode()
        floorNode.position = SCNVector3(0, positionY, positionZ)
        portal.addChildNode(floorNode)
        
        let ceilingNode = makeCeilingNode()
        ceilingNode.position = SCNVector3(0,
                                          positionY + wallHeight,
                                          positionZ)
        portal.addChildNode(ceilingNode)
        
        let farWallNode = makeWallNode()
        farWallNode.eulerAngles = SCNVector3(0, 90.0.degreeToRadians, 0)
        farWallNode.position = SCNVector3(0,
                                          positionY+wallHeight*0.5,
                                          positionZ-surfaceHeight*0.5)
        portal.addChildNode(farWallNode)
        
        let rightSideWallNode = makeWallNode(maskLowerSide: true)
        rightSideWallNode.eulerAngles = SCNVector3(0, 180.0.degreeToRadians, 0)
        rightSideWallNode.position = SCNVector3(wallLength*0.5,
                                                positionY+wallHeight*0.5,
                                                positionZ)
        portal.addChildNode(rightSideWallNode)
        
        let leftSideWallNode = makeWallNode(maskLowerSide: true)
        leftSideWallNode.position = SCNVector3(-wallLength*0.5,
                                               positionY+wallHeight*0.5,
                                               positionZ)
        portal.addChildNode(leftSideWallNode)
        
        addDoorway(node: portal)
        placeLightSource(rootNode: portal)
        return portal
    }
    
    func addDoorway(node: SCNNode){
        let halfWalllength: CGFloat = wallLength * 0.5
        let frontHalfWallLength: CGFloat = (wallLength - doorWidth) * 0.5
        let rightDoorSideNode = makeWallNode(length: frontHalfWallLength)
        rightDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreeToRadians, 0)
        rightDoorSideNode.position = SCNVector3(halfWalllength - 0.5 * doorWidth, positionY + wallLength * 0.5, positionZ + surfaceLength * 0.5)
        node.addChildNode(rightDoorSideNode)
        
        let leftDoorSideNode = makeWallNode(length: frontHalfWallLength)
        leftDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreeToRadians, 0)
        leftDoorSideNode.position = SCNVector3(-halfWalllength + 0.5 * frontHalfWallLength, positionY + wallHeight * 0.5, positionZ + surfaceLength * 0.5)
        node.addChildNode(leftDoorSideNode)
        
        let aboveDoorNode = makeWallNode(length: doorWidth, height: wallHeight - doorHeight)
        aboveDoorNode.eulerAngles = SCNVector3(0, 270.0.degreeToRadians, 0)
        aboveDoorNode.position = SCNVector3(0, positionY + (wallHeight - doorHeight) * 0.5 + doorHeight, positionZ + surfaceLength * 0.5)
        node.addChildNode(aboveDoorNode)
    }
    
    func placeLightSource(rootNode: SCNNode){
        let light = SCNLight()
        light.intensity = 10
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0, positionY + wallHeight, positionZ)
        rootNode.addChildNode(lightNode)
    }
}

extension ViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchr = anchor as? ARPlaneAnchor, !self.isPortalPlaced{
                #if DEBUG
                let debugPlaneNode = createPlaneNode(center: planeAnchr.center, extent: planeAnchr.extent)
                node.addChildNode(debugPlaneNode)
                self.debugPlanes.append(debugPlaneNode)
                #endif
                self.messageLabel.alpha = 1.0
                self.messageLabel.text = "Tap on the detected horizontal plane to place the portal"
            }else if !self.isPortalPlaced{
                self.portalNode = self.makePortal()
                if let portal = self.portalNode{
                    node.addChildNode(portal)
                    self.isPortalPlaced = true
                    self.removeDebugPlanes()
                    self.sceneView.debugOptions = []
                    DispatchQueue.main.async {
                        self.messageLabel.text = ""
                        self.messageLabel.alpha = 0
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, !node.childNodes.isEmpty, !self.isPortalPlaced{
                updatePlaneNode(node.childNodes[0], center: planeAnchor.center, extent: planeAnchor.extent)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            if let _  = self.sceneView.hitTest(self.viewCenter, types: [.existingPlaneUsingExtent]).first{
                self.crosshair.backgroundColor = UIColor.green
            }else{
                self.crosshair.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let label = self.sessionStateLabel else {return}
        showmessage(error.localizedDescription, label: label, seconds: 3)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        guard let label = self.sessionStateLabel else {return}
        showmessage("Session interrupted", label: label, seconds: 3)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        guard let label = self.sessionStateLabel else {return}
        showmessage("Session resumed", label: label, seconds: 3)
        DispatchQueue.main.async {
            self.removeAllNodes()
            self.resetLabels()
        }
        runSession()
    }
}

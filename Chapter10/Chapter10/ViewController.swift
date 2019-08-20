//
//  ViewController.swift
//  Chapter10
//
//  Created by frank.zhang on 2019/8/19.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController{
    @IBOutlet var sceneView: ARSCNView!
    weak var targetView: TargetView!
    private var billboard: BillboardContainer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        let targetView = TargetView(frame: view.bounds)
        view.addSubview(targetView)
        self.targetView = targetView
        targetView.show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuation = ARWorldTrackingConfiguration()
        sceneView.session.run(configuation)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}

extension ViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let billboard = billboard else {return nil}
        var node: SCNNode? = nil
        switch anchor {
        case billboard.billboardAnchor:
            let billboardNode = addBillboardNode()
            node = billboardNode
        default:
            break
        }
        return node
    }
}

extension ViewController: ARSessionDelegate{
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        removeBillboard()
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
}

extension ViewController{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentFrame = sceneView.session.currentFrame else {return}
        DispatchQueue.global(qos: .background).async {
            do{
                let request = VNDetectRectanglesRequest{(request, error) in
                    guard let results = request.results?.compactMap({$0 as? VNRectangleObservation}), let result = results.first else{
                        print("[Vision] VNRequest produced no result")
                        return
                    }
                    let coordinates: [matrix_float4x4] = [result.topLeft, result.topRight, result.bottomRight, result.bottomLeft].compactMap{
                        guard let hitFeature = currentFrame.hitTest($0, types: .featurePoint).first else{return nil}
                        return hitFeature.worldTransform
                    }
                    guard coordinates.count == 4 else{return}
                    
                    DispatchQueue.main.async {
                        self.removeBillboard()
                        let (topLeft, topRight, bottomRight, bottomLeft) = (coordinates[0], coordinates[1], coordinates[2], coordinates[3])
                        self.createBillboard(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
                    }
                }
                let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage)
                try handler.perform([request])
            } catch(let error){
                print("An error occurred during rectangle detection: \(error)")
            }
        }
    }
}

private extension ViewController{
    func createBillboard(topLeft: matrix_float4x4, topRight: matrix_float4x4, bottomRight: matrix_float4x4, bottomLeft: matrix_float4x4){
        let plane = RectangularPlane(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
        let anchor = ARAnchor(transform: plane.center)
        billboard = BillboardContainer(billboardAnchor: anchor, plane: plane)
        sceneView.session.add(anchor: anchor)
        print("New billboard created")
    }
    
    func addBillboardNode() -> SCNNode? {
        guard let billboard = billboard else { return nil }
        let rectangle = SCNPlane(width: billboard.plane.width, height: billboard.plane.height)
        let rectangleNode = SCNNode(geometry: rectangle)
        self.billboard?.billboardNode = rectangleNode
        return rectangleNode
    }
    
    func removeBillboard(){
        if let anchor = billboard?.billboardAnchor{
            sceneView.session.remove(anchor: anchor)
            billboard?.billboardNode?.removeFromParentNode()
            billboard = nil
        }
    }
}

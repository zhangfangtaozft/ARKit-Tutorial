//
//  ViewController.swift
//  Chapter11
//
//  Created by frank.zhang on 2019/8/20.
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
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .camera
        sceneView.session.run(configuration)
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
        case (let videoAnchor)
            where videoAnchor == billboard.videoAnchor:
            node = addVideoPlayerNode()
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
        if billboard?.hasVideosNode == true {
            billboard?.billboardNode?.isHidden = false
            removeVideo()
            return
        }
        guard let currentFrame = sceneView.session.currentFrame else {return}
        DispatchQueue.global(qos: .background).async {
            do{
                let request = VNDetectHorizonRequest{(request, error) in
                    guard let results = request.results?.compactMap({$0 as? VNBarcodeObservation}), let result = results.first else{
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
            }catch (let error){
                print("An error occurred during rectangle detection: \(error)")
            }
        }
    }
}

extension ViewController{
    func createBillboard(topLeft: matrix_float4x4, topRight: matrix_float4x4, bottomRight: matrix_float4x4, bottomLeft: matrix_float4x4){
        let plane = RectangularPlane(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
        let rotation = SCNMatrix4MakeRotation(Float.pi / 2.0, 0.0, 0.0, 1.0)
        let rotatedCenter = plane.center * matrix_float4x4(rotation)
        let anchor = ARAnchor(transform: rotatedCenter)
        billboard = BillboardContainer(billboardAnchor: anchor, plane: plane)
        sceneView.session.add(anchor: anchor)
        print("New billboard created")
    }
    
    func createVideo(){
        guard let billboard = billboard else {return}
        let rotation = SCNMatrix4MakeRotation(Float.pi / 2.0, 0.0, 0.0, 1.0)
        let rotatedCenter = billboard.plane.center * matrix_float4x4(rotation)
        let anchor = ARAnchor(transform: rotatedCenter)
        sceneView.session.add(anchor: anchor)
        self.billboard?.videoAnchor = anchor
    }
    
    func addBillboardNode() -> SCNNode?{
        guard let billboard = billboard else {return nil}
        let rectangle = SCNPlane(width: billboard.plane.width, height: billboard.plane.height)
        let rectangleNode = SCNNode(geometry: rectangle)
        self.billboard?.billboardNode = rectangleNode
        let images = ["logo_1", "logo_2", "logo_3", "logo_4", "logo_5"].map{UIImage(named: $0)!}
        setBillboardImages(images)
        return rectangleNode
    }
    
    func addVideoPlayerNode() -> SCNNode?{
        guard let billboard = billboard else {return nil}
        let billboardSize = CGSize(width: billboard.plane.width, height: billboard.plane.height / 2)
        let frameSize = CGSize(width: 1024, height: 512)
        let videoUrl = URL(string: "https://www.rmp-streaming.com/media/bbb-360p.mp4")!
        let player = AVPlayer(url: videoUrl)
        let videoPlayerNode = SKVideoNode(avPlayer: player)
        videoPlayerNode.size = frameSize
        videoPlayerNode.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
        videoPlayerNode.zRotation = CGFloat.pi
        let spritekitScene = SKScene(size: frameSize)
        spritekitScene.addChild(videoPlayerNode)
        
        let plane = SCNPlane(width: billboardSize.width, height: billboardSize.height)
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.diffuse.contents = spritekitScene
        let node = SCNNode(geometry: plane)
        self.billboard?.videoNode = node
        self.billboard?.billboardNode?.isHidden = true
        videoPlayerNode.play()
        return node
    }
    
    func removeBillboard(){
        if let anchor = billboard?.billboardAnchor {
            if let viewController = billboard?.viewController{
                viewController.willMove(toParent: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
            }
            sceneView.session.remove(anchor: anchor)
            billboard?.billboardNode?.removeFromParentNode()
            billboard = nil
        }
    }
    
    func removeVideo(){
        if let videoAnchor = billboard?.videoAnchor {
            sceneView.session.remove(anchor: videoAnchor)
        }
        billboard?.videoNode?.removeFromParentNode()
        billboard?.videoAnchor = nil
        billboard?.videoNode = nil
    }
    
    func setBillboardImages(_ images: [UIImage]){
        let material = SCNMaterial()
        material.isDoubleSided = true
        DispatchQueue.main.async {
            let billboardViewController = BillboardViewController(nibName: "BillboardViewController", bundle: nil)
            billboardViewController.delegate = self
            billboardViewController.images = images
            
            material.diffuse.contents = billboardViewController.view
            self.billboard?.viewController = billboardViewController
            self.billboard?.billboardNode?.geometry?.materials = [material]
        }
    }
}

extension ViewController: BillboardViewDelegate{
    func billboardViewDidSelectPlayVideo(_ view: BillboardView) {
        createVideo()
    }
}

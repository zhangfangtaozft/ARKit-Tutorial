//
//  ViewController.swift
//  Chapter03
//
//  Created by frank.zhang on 2019/8/5.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    var trackingStatus: String = ""
    var focusNode: SCNNode!
    var diceNodes: [SCNNode] = []
    var diceCount: Int = 1
    var diceStyle: Int = 0
    var diceOffset: [SCNVector3] = [SCNVector3(0.0,0.0,0.0),
                                    SCNVector3(-0.05, 0.00, 0.0),
                                    SCNVector3(0.05, 0.00, 0.0),
                                    SCNVector3(-0.05, 0.05, 0.02),
                                    SCNVector3(0.05, 0.05, 0.02)]
    
    // MARK: - Outlets
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var styleButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func startButtonPressed(_ sender: Any) {
    }
    
    @IBAction func styleButtonPressed(_ sender: Any) {
        diceStyle = diceStyle >= 4 ? 0 : diceStyle + 1
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
    }
    
    @IBAction func swipeUpGestureHandler(_ sender: Any) {
        // 1
        guard let frame = self.sceneView.session.currentFrame else { return }
        // 2
        for count in 0..<diceCount {
            throwDiceNode(transform: SCNMatrix4(frame.camera.transform),
                          offset: diceOffset[count])
        }
    }
    
    // MARK: - View Management
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSceneView()
        self.initScene()
        self.initARSession()
        self.loadModels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("*** ViewWillAppear()")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("*** ViewWillDisappear()")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("*** DidReceiveMemoryWarning()")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Initialization
    
    func initSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [
            //ARSCNDebugOptions.showFeaturePoints,
            //ARSCNDebugOptions.showWorldOrigin,
            //SCNDebugOptions.showBoundingBoxes,
            //SCNDebugOptions.showWireframe
        ]
    }
    
    func initScene() {
        let scene = SCNScene()
        scene.isPaused = false
        sceneView.scene = scene
        scene.lightingEnvironment.contents = "ARResource.scnassets/Textures/Environment_cube.jpg"
        scene.lightingEnvironment.intensity = 2
    }
    
    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        sceneView.session.run(config)
    }
    
    // MARK: - Load Models
    func loadModels() {
        // 1
        let diceScene = SCNScene(
            named: "ARResource.scnassets/DiceScene.scn")!
        // 2
        for count in 0..<5 {
            // 3
            diceNodes.append(diceScene.rootNode.childNode(
                withName: "Dice\(count)",
                recursively: false)!)
        }
        
        let focusScene = SCNScene(
            named: "ARResource.scnassets/Models/FocusScene.scn")!
        focusNode = focusScene.rootNode.childNode(
            withName: "focus", recursively: false)!
        
        sceneView.scene.rootNode.addChildNode(focusNode)
    }
    
    // MARK: - Helper Functions
    func throwDiceNode(transform: SCNMatrix4, offset: SCNVector3) {
        // 1
        let position = SCNVector3(transform.m41 + offset.x,
                                  transform.m42 + offset.y,
                                  transform.m43 + offset.z)
        // 2
        let diceNode = diceNodes[diceStyle].clone()
        diceNode.name = "dice"
        diceNode.position = position
        //3
        sceneView.scene.rootNode.addChildNode(diceNode)
        //diceCount -= 1
    }
}

extension ViewController : ARSCNViewDelegate {
    
    // MARK: - SceneKit Management
    
    func renderer(_ renderer: SCNSceneRenderer,
                  updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.statusLabel.text = self.trackingStatus
        }
    }
    
    
    // MARK: - Session State Management
    
    func session(_ session: ARSession,
                 cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        // 1
        case .notAvailable:
            self.trackingStatus = "Tacking:  Not available!"
            break
        // 2
        case .normal:
            self.trackingStatus = "Tracking: All Good!"
            break
        // 3
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                self.trackingStatus = "Tracking: Limited due to excessive motion!"
                break
            // 3.1
            case .insufficientFeatures:
                self.trackingStatus = "Tracking: Limited due to insufficient features!"
                break
            // 3.2
            case .initializing:
                self.trackingStatus = "Tracking: Initializing..."
                break
            case .relocalizing:
                self.trackingStatus = "Tracking: Relocalizing..."
            }
        }
    }
    
    // MARK: - Session Error Managent
    
    func session(_ session: ARSession,
                 didFailWithError error: Error) {
        self.trackingStatus = "AR Session Failure: \(error)"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        self.trackingStatus = "AR Session Was Interrupted!"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        self.trackingStatus = "AR Session Interruption Ended"
    }
    
    // MARK: - Plane Management
    
}


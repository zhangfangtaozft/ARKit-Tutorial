//
//  ViewController.swift
//  Chapter16
//
//  Created by frank.zhang on 2019/9/10.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum ContentType: Int {
    case none
    case mask
    case glasses
    case pig
}

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    
    var session: ARSession {
        return sceneView.session
    }
    
    var contentTypeSelected: ContentType = .none
    
    var anchorNode: SCNNode?
    var mask: Mask?
    var maskType = MaskType.zombie
    var glasses: Glasses?
    var pig: Pig?
    
    // MARK: - View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        createFaceGeometry()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Button Actions
    
    @IBAction func didTapReset(_ sender: Any) {
        print("didTapReset")
        contentTypeSelected = .none
        resetTracking()
    }
    
    @IBAction func didTapMask(_ sender: Any) {
        print("didTapMask")
        
        switch maskType {
        case .basic:
            maskType = .zombie
        case .painted:
            maskType = .basic
        case .zombie:
            maskType = .painted
        }
        
        mask?.swapMaterials(maskType: maskType)
        
        contentTypeSelected = .mask
        resetTracking()
    }
    
    @IBAction func didTapGlasses(_ sender: Any) {
        print("didTapGlasses")
        contentTypeSelected = .glasses
        resetTracking()
    }
    
    @IBAction func didTapPig(_ sender: Any) {
        print("didTapPig")
        contentTypeSelected = .pig
        resetTracking()
    }
    
    @IBAction func didTapRecord(_ sender: Any) {
        print("didTapRecord")
    }
}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    
    // Tag: SceneKit Renderer
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // 1
        guard let estimate = session.currentFrame?.lightEstimate else {
            return
        }
        
        // 2
        let intensity = estimate.ambientIntensity / 1000.0
        sceneView.scene.lightingEnvironment.intensity = intensity
        
        // 3
        let intensityStr = String(format: "%.2f", intensity)
        let sceneLighting = String(format: "%.2f",
                                   sceneView.scene.lightingEnvironment.intensity)
        
        // 4
        print("Intensity: \(intensityStr) - \(sceneLighting)")
    }
    
    // Tag: ARNodeTracking
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        anchorNode = node
        setupFaceNodeContent()
    }
    
    // Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        updateMessage(text: "Tracking your face.")
        
        switch contentTypeSelected {
        case .none: break
        case .mask:
            mask?.update(withFaceAnchor: faceAnchor)
        case .glasses:
            glasses?.update(withFaceAnchor: faceAnchor)
        case .pig:
            pig?.update(withFaceAnchor: faceAnchor)
        }
    }
    
    // Tag: ARSession Handling
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("** didFailWithError")
        updateMessage(text: "Session failed.")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("** sessionWasInterrupted")
        updateMessage(text: "Session interrupted.")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("** sessionInterruptionEnded")
        updateMessage(text: "Session interruption ended.")
    }
}

// MARK: - Private methods

private extension ViewController {
    
    // Tag: SceneKit Setup
    func setupScene() {
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Setup environment
        sceneView.automaticallyUpdatesLighting = true /* default setting */
        sceneView.autoenablesDefaultLighting = false /* default setting */
        sceneView.scene.lightingEnvironment.intensity = 1.0 /* default setting */
    }
    
    // Tag: ARFaceTrackingConfiguration
    func resetTracking() {
        // 1
        guard ARFaceTrackingConfiguration.isSupported else {
            updateMessage(text: "Face Tracking Not Supported.")
            return
        }
        
        // 2
        updateMessage(text: "Looking for a face.")
        
        // 3
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true /* default setting */
        configuration.providesAudioData = false /* default setting */
        
        // 4
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // Tag: CreateARSCNFaceGeometry
    func createFaceGeometry() {
        updateMessage(text: "Creating face geometry.")
        
        let device = sceneView.device!
        
        let maskGeometry = ARSCNFaceGeometry(device: device)!
        mask = Mask(geometry: maskGeometry, maskType: maskType)
        
        let glassesGeometry = ARSCNFaceGeometry(device: device)!
        glasses = Glasses(geometry: glassesGeometry)
        
        let pigGeometry = ARSCNFaceGeometry(device: device)!
        pig = Pig(geometry: pigGeometry)
    }
    
    // Tag: Setup Face Content Nodes
    func setupFaceNodeContent() {
        guard let node = anchorNode else { return }
        
        node.childNodes.forEach { $0.removeFromParentNode() }
        
        switch contentTypeSelected {
        case .none: break
        case .mask:
            if let content = mask {
                node.addChildNode(content)
            }
        case .glasses:
            if let content = glasses {
                node.addChildNode(content)
            }
        case .pig:
            if let content = pig {
                node.addChildNode(content)
            }
        }
    }
    
    // Tag: Update UI
    func updateMessage(text: String) {
        DispatchQueue.main.async {
            self.messageLabel.text = text
        }
    }
}

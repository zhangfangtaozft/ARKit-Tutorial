//
//  ViewController.swift
//  Chapter14
//
//  Created by frank.zhang on 2019/9/9.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController{

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    
    var session: ARSession{
        return sceneView.session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      setupScene()
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
    
    @IBAction func didTapReset(_ sender: Any) {
        print("didTapReset")
        resetTracking()
    }
    
    
    @IBAction func didTapMask(_ sender: Any) {
        print("didTapMask")
    }
    
    @IBAction func didTapGlasses(_ sender: Any) {
        print("didTapGlasses")
    }
    
    @IBAction func didTapPig(_ sender: Any) {
        print("didTapPig")
    }
    
    @IBAction func didTapRecord(_ sender: Any) {
         print("didTapRecord")
    }
}

extension ViewController: ARSCNViewDelegate {

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

    func setupScene() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
    }
    
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            updateMessage(text: "Face Tracking Not Supported.")
            return
        }
        updateMessage(text: "Looking for a face.")
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true /* default setting */
        configuration.providesAudioData = false /* default setting */
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func updateMessage(text: String) {
        DispatchQueue.main.async {
            self.messageLabel.text = text
        }
    }
}

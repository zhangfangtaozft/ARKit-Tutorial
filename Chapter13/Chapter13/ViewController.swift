//
//  ViewController.swift
//  Chapter13
//
//  Created by frank.zhang on 2019/8/28.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var autoscanButton: UIButton!
    @IBOutlet weak var removeBillboardButton: UIButton!
    @IBOutlet weak var toggleLocationTrackingButton: UIButton!
    @IBOutlet weak var beaconStatusImage: UIImageView!
    @IBOutlet weak var beaconStatusLabel: UILabel!
    weak var targetView: TargetView!
    
    private var billboard: BillboardContainer?
    private var autoscanTimer: Timer?
    
    private var locationManager = LocationManager()
    
    // Flag indicating if timer is on when the view is hidden
    private var wasTimerActive = false
    
    // Flag indicating if location tracking is active
    private var isLocationTrackingActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Set the session's delegate
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Initialize core location
        locationManager.initialize()
        locationManager.delegate = self
        
        // Setup the target view
        let targetView = TargetView(frame: view.bounds)
        view.addSubview(targetView)
        self.targetView = targetView
        targetView.show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .camera
        
        var triggerImages = ARReferenceImage.referenceImages(inGroupNamed: "RMK-ARKit-triggers", bundle: nil)
        
        let image = UIImage(named: "logo_2")!
        let referenceImage = ARReferenceImage(image.cgImage!, orientation: .up, physicalWidth: 0.2)
        triggerImages?.insert(referenceImage)
        
        configuration.detectionImages = triggerImages
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        if wasTimerActive {
            // Start the timer
            startAutoscanTimer()
            wasTimerActive = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
        if isTimerRunning {
            wasTimerActive = true
            stopAutoscanTimer()
        }
    }
    
    @IBAction func didTapRemoveBillboard() {
        removeBillboard()
    }
    
    @IBAction func didTapToggleAutoScan() {
        if isTimerRunning {
            stopAutoscanTimer()
        } else {
            startAutoscanTimer()
        }
    }
    
    @IBAction func toggleLocationTracking() {
        isLocationTrackingActive = !isLocationTrackingActive
        
        if isLocationTrackingActive {
            self.toggleLocationTrackingButton.setImage(#imageLiteral(resourceName: "arKit-fence-on"), for: .normal)
            
            let rmkLocation = Constants.razewareMobileKioskLocation
            let rmkCoordinates = rmkLocation.location
            print("")
            print("=========================================================================================================")
            print("WARNING: ensure that the Razeware Mobile Kiosk is at a location near you,")
            print("otherwise geofencing and beacon detection won't work")
            print("The current location is: \(rmkLocation.name) (\(rmkLocation.location.latitude), \(rmkLocation.location.longitude))")
            print("=========================================================================================================")
            
            do {
                try locationManager.startMonitoring(location: rmkCoordinates, radius: Constants.geofencingRadius, identifier: Constants.razewareMobileKioskIdentifier)
            } catch (let error as LocationManager.GeofencingError) {
                print("An error occurred while monitoring a region: \(error)")
            } catch (let error) {
                print("Tracking location error: \(error.localizedDescription)")
            }
        } else {
            self.toggleLocationTrackingButton.setImage(#imageLiteral(resourceName: "arKit-fence-off"), for: .normal)
            locationManager.stopMonitoringRegions()
            locationManager.stopMonitoring(beacons: Constants.razeadBeacons)
            beaconStatusImage.isHidden = true
            beaconStatusLabel.isHidden = true
            stopAutoscanTimer()
        }
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let billboard = billboard else { return nil }
        var node: SCNNode? = nil
        DispatchQueue.main.sync {
            switch anchor {
            case billboard.billboardAnchor:
                let billboardNode = addBillboardNode()
                self.createBillboardController()
                node = billboardNode
                
            case (let videoAnchor) where videoAnchor == billboard.videoAnchor:
                node = billboard.videoNodeHandler?.createNode()
                
            default:
                break
            }
        }
        
        return node
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        removeBillboard()
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if let imageAnchor = anchors.compactMap({ $0 as? ARImageAnchor }).first {
            self.createBillboard(center: imageAnchor.transform, size: imageAnchor.referenceImage.physicalSize)
        }
    }
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if billboard?.hasVideoNode == true {
            billboard?.billboardNode?.isHidden = false
            billboard?.videoNodeHandler?.removeNode()
            return
        }
    }
    
    private func scanQRCode() {
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        DispatchQueue.global(qos: .background).async {
            do {
                let request = VNDetectBarcodesRequest { (request, error) in
                    // Access the first result in the array,
                    // after converting to an array
                    // of VNBarcodeObservation
                    guard let results = request.results?.compactMap({ $0 as? VNBarcodeObservation }), let result = results.first else {
                        print ("[Vision] VNRequest produced no result")
                        return
                    }
                    
                    let coordinates: [matrix_float4x4] = [result.topLeft, result.topRight, result.bottomRight, result.bottomLeft].compactMap {
                        guard let hitFeature = currentFrame.hitTest($0, types: .featurePoint).first else { return nil }
                        return hitFeature.worldTransform
                    }
                    
                    guard coordinates.count == 4 else { return }
                    
                    DispatchQueue.main.async {
                        self.removeBillboard()
                        
                        // Stop the timer
                        self.stopAutoscanTimer()
                        
                        // Remove the target
                        self.targetView.hide()
                        
                        let (topLeft, topRight, bottomRight, bottomLeft) = (coordinates[0], coordinates[1], coordinates[2], coordinates[3])
                        self.createBillboard(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
                        
                        // Uncomment to show four small placeholders in correspondence of the plane vertices
                        /*
                         for coordinate in coordinates {
                         let box = SCNBox(width: 0.01, height: 0.01, length: 0.001, chamferRadius: 0.0)
                         let node = SCNNode(geometry: box)
                         node.transform = SCNMatrix4(coordinate)
                         self.sceneView.scene.rootNode.addChildNode(node)
                         }
                         */
                    }
                }
                
                let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage)
                try handler.perform([request])
            } catch(let error) {
                print("An error occurred during rectangle detection: \(error)")
            }
        }
    }
}

private extension ViewController {
    func createBillboard(topLeft: matrix_float4x4, topRight: matrix_float4x4, bottomRight: matrix_float4x4, bottomLeft: matrix_float4x4) {
        autoscanButton.isEnabled = false
        removeBillboardButton.isEnabled = true
        
        let plane = RectangularPlane(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
        let rotation =
            SCNMatrix4MakeRotation(Float.pi / 2.0, 0.0, 0.0, 1.0)
        let rotatedCenter =
            plane.center * matrix_float4x4(rotation)
        let anchor = ARAnchor(transform: rotatedCenter)
        billboard = BillboardContainer(billboardAnchor: anchor, plane: plane)
        billboard?.videoPlayerDelegate = self
        sceneView.session.add(anchor: anchor)
        
        print("New billboard created")
    }
    
    func createBillboard(center: matrix_float4x4, size: CGSize) {
        let plane = RectangularPlane(center: center, size: size)
        let rotation =
            SCNMatrix4MakeRotation(Float.pi / 2, -1.0, 0.0, 0.0)
        let rotatedCenter =
            plane.center * matrix_float4x4(rotation)
        let anchor = ARAnchor(transform: rotatedCenter)
        billboard = BillboardContainer(billboardAnchor: anchor, plane: plane)
        billboard?.videoPlayerDelegate = self
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
    
    
    func removeBillboard() {
        if let anchor = billboard?.billboardAnchor {
            if let viewController = billboard?.viewController {
                viewController.willMove(toParent: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
            }
            
            sceneView.session.remove(anchor: anchor)
            billboard?.billboardNode?.removeFromParentNode()
            
            billboard?.videoNodeHandler = nil
            
            billboard = nil
        }
    }
    
    func createBillboardController() {
        DispatchQueue.main.async {
            let navController = UIStoryboard(name: "Billboard", bundle: nil).instantiateInitialViewController() as! UINavigationController
            let billboardViewController = navController.visibleViewController as! BillboardViewController
            billboardViewController.sceneView = self.sceneView
            billboardViewController.billboard = self.billboard
            
            billboardViewController.willMove(toParent: self)
            self.addChild(billboardViewController)
            self.view.addSubview(billboardViewController.view)
            
            self.show(viewController: billboardViewController)
        }
    }
    
    private func show(viewController: BillboardViewController) {
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.cullMode = .front
        
        material.diffuse.contents = viewController.view
        
        billboard?.viewController = viewController
        billboard?.billboardNode?.geometry?.materials = [material]
    }
}

extension ViewController: VideoPlayerDelegate {
    func didStartPlay() {
        billboard?.billboardNode?.isHidden = true
    }
    
    func didEndPlay() {
        billboard?.billboardNode?.isHidden = false
    }
}

// MARK: - Timer
extension ViewController {
    func startAutoscanTimer() {
        guard isTimerRunning == false else { return }
        
        targetView.show()
        
        autoscanTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(didFireTimer(timer:)), userInfo: nil, repeats: true)
        autoscanButton.setImage(#imageLiteral(resourceName: "arKit-radar-on"), for: .normal)
    }
    
    func stopAutoscanTimer() {
        targetView.hide()
        
        // Stops the timer
        autoscanTimer?.invalidate()
        autoscanTimer = nil
        autoscanButton.setImage(#imageLiteral(resourceName: "arKit-radar-off"), for: .normal)
    }
    
    var isTimerRunning: Bool {
        guard let timer = autoscanTimer else { return false }
        return timer.isValid
    }
    
    @objc func didFireTimer(timer: Timer) {
        scanQRCode()
    }
}

// MARK: - LocationManagerDelegate
extension ViewController: LocationManagerDelegate {
    // MARK: Location
    func locationManager(_ locationManager: LocationManager, didEnterRegionId regionId: String) {
        // Notify the user that he's entered the geofenced zone
        let message = "\(regionId) is less than \(String(format: "%0.0f", Constants.geofencingRadius)) meters. Come say hi and interact with our e-billboard"
        let title = regionId
        
        showAlert(with: "geofencing-notification", title: title, message: message)
        
        locationManager.startMonitoring(beacons: Constants.razeadBeacons)
    }
    
    func locationManager(_ locationManager: LocationManager, didExitRegionId regionId: String) {
        // In case the autoscan timer is still active, disables it because there's nothing to scan
        locationManager.stopMonitoring(beacons: Constants.razeadBeacons)
        stopAutoscanTimer()
        beaconStatusImage.isHidden = true
        beaconStatusLabel.isHidden = true
    }
    
    // MARK: Beacons
    func locationManager(_ locationManager: LocationManager, didRangeBeacon beacon: CLBeacon) {
        beaconStatusImage.isHidden = false
        beaconStatusLabel.isHidden = false
        
        switch beacon.proximity {
        case .immediate:
            beaconStatusImage.image = #imageLiteral(resourceName: "arKit-marker-1")
        case .near:
            beaconStatusImage.image = #imageLiteral(resourceName: "arKit-marker-2")
        case .far:
            beaconStatusImage.image = #imageLiteral(resourceName: "arKit-marker-3")
        case .unknown:
            beaconStatusImage.image = #imageLiteral(resourceName: "arKit-marker-4")
        }
        
        // Start auto scan, but only if the app is in the foreground
        // and there is no active billboard
        if UIApplication.shared.applicationState == .active && (billboard == nil || billboard?.hasBillboardNode == false) {
            startAutoscanTimer()
        }
    }
    
    func locationManager(_ locationManager: LocationManager, didLeaveBeacon beacon: CLBeacon) {
        stopAutoscanTimer()
        beaconStatusImage.isHidden = true
        beaconStatusLabel.isHidden = true
    }
}

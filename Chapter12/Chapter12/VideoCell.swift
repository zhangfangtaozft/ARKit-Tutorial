//
//  VideoCell.swift
//  Chapter12
//
//  Created by frank.zhang on 2019/8/26.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import ARKit

class VideoCell: UICollectionViewCell {
    var isPlaying = false
    var videoNode: SKVideoNode!
    var spriteScene: SKScene!
    var videoUrl: String!
    var player: AVPlayer?
    weak var billboard: BillboardContainer?
    weak var sceneView: ARSCNView?
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerContainer: UIView!
    
    func configure(videoUrl: String, sceneView: ARSCNView, billboard: BillboardContainer) {
        self.videoUrl = videoUrl
        self.billboard = billboard
        self.sceneView = sceneView
        billboard.videoNodeHandler = self
    }
    
    func createVideoPlayerAnchor() {
        guard let billboard = billboard else { return }
        guard let sceneView = sceneView else { return }
        
        let center = billboard.plane.center * matrix_float4x4(SCNMatrix4MakeRotation(Float.pi / 2.0, 0.0, 0.0, 1.0))
        let anchor = ARAnchor(transform: center)
        sceneView.session.add(anchor: anchor)
        billboard.videoAnchor = anchor
    }
    
    func createVideoPlayerView() {
        if player == nil {
            guard let url = URL(string: videoUrl) else { return }
            player = AVPlayer(url: url)
            let layer = AVPlayerLayer(player: player)
            layer.frame = playerContainer.bounds
            playerContainer.layer.addSublayer(layer)
        }
        
        player?.play()
    }
    
    func stopVideo() {
        player?.pause()
    }
    
    @IBAction func play() {
        guard let billboard = billboard else { return }
        
        if billboard.isFullScreen {
            if isPlaying == false {
                createVideoPlayerView()
                playButton.setImage(#imageLiteral(resourceName: "arKit-pause"), for: .normal)
            } else {
                stopVideo()
                playButton.setImage(#imageLiteral(resourceName: "arKit-play"), for: .normal)
            }
            isPlaying = !isPlaying
        } else {
            createVideoPlayerAnchor()
            billboard.videoPlayerDelegate?.didStartPlay()
            playButton.isEnabled = false
        }
    }
}

extension VideoCell: VideoNodeHandler {
    func createNode() -> SCNNode? {
        guard let billboard = billboard else { return nil }
        
        let frameSize = CGSize(width: 1024, height: 1024)
        let url = URL(string: videoUrl)!
        
        let player = AVPlayer(url: url)
        videoNode = SKVideoNode(avPlayer: player)
        videoNode.size = frameSize
        videoNode.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
        videoNode.zRotation = CGFloat.pi
        
        spriteScene = SKScene(size: frameSize)
        spriteScene.scaleMode = .aspectFit
        spriteScene.backgroundColor = UIColor(white: 33/255, alpha: 1.0)
        spriteScene.addChild(videoNode)
        
        let billboardSize = CGSize(width: billboard.plane.width, height: billboard.plane.height / 2)
        let plane = SCNPlane(width: billboardSize.width, height: billboardSize.height)
        plane.firstMaterial!.isDoubleSided = true
        plane.firstMaterial!.diffuse.contents = spriteScene
        let node = SCNNode(geometry: plane)
        
        billboard.videoNode = node
        
        billboard.videoNodeHandler = self
        
        videoNode.play()
        return node
    }
    
    func removeNode() {
        videoNode?.pause()
        
        spriteScene?.removeAllChildren()
        spriteScene = nil
        
        if let videoAnchor = billboard?.videoAnchor {
            sceneView?.session.remove(anchor: videoAnchor)
        }
        
        billboard?.videoPlayerDelegate?.didEndPlay()
        
        billboard?.videoNode?.removeFromParentNode()
        billboard?.videoAnchor = nil
        billboard?.videoNode = nil
        
        playButton.isEnabled = true
    }
}

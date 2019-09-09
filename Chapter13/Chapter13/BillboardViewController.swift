//
//  BillboardViewController.swift
//  Chapter13
//
//  Created by frank.zhang on 2019/9/6.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import ARKit

private enum Section: Int {
    case images = 1
    case video = 0
    case webBrowser = 2
}

private enum Cell: String {
    case cellWebBrowser
    case cellVideo
    case cellImage
}

class BillboardViewController: UICollectionViewController {
    var sceneView: ARSCNView?
    var billboard: BillboardContainer?
    weak var mainViewController: ViewController?
    weak var mainView: UIView?
    
    var images: [String] = ["logo_1", "logo_2", "logo_3", "logo_4", "logo_5"]
    let doubleTapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.addTarget(self, action: #selector(didDoubleTap))
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func didDoubleTap() {
        guard let billboard = billboard else { return }
        if billboard.isFullScreen {
            restoreFromFullScreen()
        } else {
            showFullScreen()
        }
    }
}

// UICollectionViewDelegate
extension BillboardViewController {
    
}

// UICollectionViewDataSource
extension BillboardViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentSection = Section(rawValue: section) else { return 0 }
        
        switch currentSection {
        case .images:
            return images.count
        case .video:
            return 1
        case .webBrowser:
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let currentSection = Section(rawValue: indexPath.section) else { fatalError("Unexpected collection view section") }
        
        let cellType: Cell
        switch currentSection {
        case .images:
            cellType = .cellImage
        case .video:
            cellType = .cellVideo
        case .webBrowser:
            cellType = .cellWebBrowser
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.rawValue, for: indexPath)
        
        switch cell {
        case let imageCell as ImageCell:
            let image = UIImage(named: images[indexPath.row])!
            imageCell.show(image: image)
            
        case let videoCell as VideoCell:
            let videoUrl = "https://www.rmp-streaming.com/media/bbb-360p.mp4"
            if let sceneView = sceneView, let billboard = billboard {
                videoCell.configure(videoUrl: videoUrl, sceneView: sceneView, billboard: billboard)
            }
            break
            
        case let webBrowserCell as WebBrowserCell:
            webBrowserCell.go(to: "https://www.raywenderlich.com")
            
        default:
            fatalError("Unrecognized cell")
        }
        
        return cell
    }
}

extension BillboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

extension BillboardViewController {
    func showFullScreen() {
        guard let billboard = billboard else { return }
        guard billboard.isFullScreen == false else { return }
        
        guard let mainViewController = parent as? ViewController else { return }
        self.mainViewController = mainViewController
        mainView = view.superview
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        
        willMove(toParent: mainViewController)
        mainViewController.view.addSubview(view)
        mainViewController.addChild(self)
        
        billboard.isFullScreen = true
    }
    
    func restoreFromFullScreen() {
        guard let billboard = billboard else { return }
        guard billboard.isFullScreen == true else { return }
        guard let mainViewController = mainViewController else { return }
        guard let mainView = mainView else { return }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        
        willMove(toParent: mainViewController)
        mainView.addSubview(view)
        mainViewController.addChild(self)
        
        billboard.isFullScreen = false
        self.mainViewController = nil
        self.mainView = nil
    }
}

//
//  BillboardView.swift
//  Chapter11
//
//  Created by frank.zhang on 2019/8/20.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
protocol BillboardViewDelegate: class {
    func billboardViewDidSelectPlayVideo(_ view: BillboardView)
}
class BillboardView: UIView {
    @IBOutlet weak var currentImageView: UIImageView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    weak var delegate: BillboardViewDelegate?
    
    private var currentIndex: Int = 0
    
    func showPreviousImage() {
        let currentX = currentImageView.frame.origin.x
        let newIndex: Int = {
            var index = (self.currentIndex - 1) % self.images.count
            if index < 0 {
                index = self.images.count + index
            }
            return index
        }()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.currentImageView.frame.origin.x += self.bounds.width
        }, completion: { (finished) in
            self.currentImageView.frame.origin.x = -self.currentImageView.frame.width
            self.showImage(at: newIndex)
            UIView.animate(withDuration: 0.5, animations: {
                self.currentImageView.frame.origin.x = currentX
            })
        })
    }
    
    func showNextImage() {
        let currentX = currentImageView.frame.origin.x
        let newIndex: Int = (currentIndex + 1) % images.count
        
        UIView.animate(withDuration: 0.2, animations: {
            self.currentImageView.frame.origin.x -= self.bounds.width
        }, completion: { (finished) in
            self.currentImageView.frame.origin.x = self.currentImageView.frame.width + currentX
            self.showImage(at: newIndex)
            UIView.animate(withDuration: 0.5, animations: {
                self.currentImageView.frame.origin.x = currentX
            })
        })
    }
    
    private func showImage(at index: Int) {
        currentIndex = index
        currentImageView.image = images[currentIndex]
    }
    
    var images: [UIImage]! {
        didSet {
            showImage(at: 0)
        }
    }
    
    @IBAction func preAction(_ sender: Any) {
        showPreviousImage()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        showNextImage()
    }
    
    @IBAction func playAction(_ sender: Any) {
        self.delegate?.billboardViewDidSelectPlayVideo(self)
    }
}

//
//  TargetView.swift
//  Chapter11
//
//  Created by frank.zhang on 2019/8/20.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit

class TargetView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    private func configureView(){
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
        isHidden = true
    }
    
    func show(){
        guard let finalFrame = superview?.bounds else {return}
        frame = CGRect(origin: CGPoint(x: finalFrame.width / 2, y: finalFrame.height / 2), size: .zero)
        isHidden = false
        UIView.animate(withDuration: 1.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.frame = finalFrame
        })
    }

    func hide(){
      let finalFrame = CGRect(origin: CGPoint(x: bounds.width / 2, y: bounds.height / 2), size: .zero)
        UIView.animate(withDuration: 1.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseIn, animations: {
            self.frame = finalFrame
        }) { _ in
            self.isHidden = true
        }
    }
    
    override func draw(_ rect: CGRect) {
        let targetLength: CGFloat = 30
        let size = min(self.bounds.width, self.bounds.height) - 100
        let frame = CGRect(origin: CGPoint(x: center.x - size / 2, y: center.y - size / 2), size: CGSize(width: size, height: size))
        let topLeft = frame.origin
        let topRight = CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y)
        let bottomLeft = CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height)
        let bottomRight = CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height)
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(1.0)
        context?.setStrokeColor(UIColor.lightGray.cgColor)
        
        
        context?.move(to: CGPoint(x: topLeft.x, y: topLeft.y + targetLength))
        context?.addLine(to: topLeft)
        context?.addLine(to: CGPoint(x: topLeft.x + targetLength, y: topLeft.y))
        
        context?.move(to: CGPoint(x: topRight.x, y: topRight.y + targetLength))
        context?.addLine(to: topRight)
        context?.addLine(to: CGPoint(x: topRight.x - targetLength, y: topRight.y))
        
        context?.move(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - targetLength))
        context?.addLine(to: bottomLeft)
        context?.addLine(to: CGPoint(x: bottomLeft.x + targetLength, y: bottomLeft.y))
        
        context?.move(to: CGPoint(x: bottomRight.x, y: bottomRight.y - targetLength))
        context?.addLine(to: bottomRight)
        context?.addLine(to: CGPoint(x: bottomRight.x - targetLength, y: bottomRight.y))
        context?.strokePath()
    }
}

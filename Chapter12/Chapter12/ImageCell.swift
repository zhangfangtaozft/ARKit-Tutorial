//
//  ImageCell.swift
//  Chapter12
//
//  Created by frank.zhang on 2019/8/26.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func show(image: UIImage) {
        imageView.image = image
    }
}

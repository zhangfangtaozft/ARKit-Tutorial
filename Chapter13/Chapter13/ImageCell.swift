//
//  ImageCell.swift
//  Chapter13
//
//  Created by frank.zhang on 2019/9/9.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func show(image: UIImage) {
        imageView.image = image
    }
}

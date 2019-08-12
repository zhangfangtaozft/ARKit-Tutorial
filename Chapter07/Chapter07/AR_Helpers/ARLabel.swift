//
//  ARLabel.swift
//  Chapter07
//
//  Created by frank.zhang on 2019/8/12.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit

class ARLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let inserts = UIEdgeInsets.init(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        super.drawText(in: rect.inset(by: inserts))
    }
}

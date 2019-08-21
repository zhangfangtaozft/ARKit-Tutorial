//
//  BillboardViewController.swift
//  Chapter11
//
//  Created by frank.zhang on 2019/8/20.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit

class BillboardViewController: UIViewController {
    private var _view: BillboardView{return view as! BillboardView}
    var delegate: BillboardViewDelegate?{
        get {return _view.delegate}
        set{_view.delegate = newValue}
    }
    
    var images: [UIImage]{
        get{return _view.images}
        set{_view.images = newValue}
    }
}

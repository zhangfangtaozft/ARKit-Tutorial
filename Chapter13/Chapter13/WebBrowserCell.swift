//
//  WebBrowserCell.swift
//  Chapter13
//
//  Created by frank.zhang on 2019/9/9.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit

class WebBrowserCell: UICollectionViewCell {
    @IBOutlet weak var webBrowser: UIWebView!
    
    func go(to urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webBrowser.loadRequest(request)
    }
}

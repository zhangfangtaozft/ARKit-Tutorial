/**
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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

extension BillboardViewController : UICollectionViewDelegateFlowLayout {
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

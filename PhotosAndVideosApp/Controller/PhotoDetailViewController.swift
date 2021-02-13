//
//  PhotoDetailViewController.swift
//  PhotosAndVideosApp
//
//  Created by Binil V on 13/02/21.
//

import UIKit

class PhotoDetailViewController: UIViewController , UIScrollViewDelegate{

  @IBOutlet weak var navTitlelLabel: UILabel!
  @IBOutlet var fullScreenImage: UIImageView!
  @IBOutlet var scrolViewContainer: UIScrollView!
  @IBOutlet weak var buttonControlView: UIView!
  var imageToDisplay = UIImage()
  var imageURL: String? = ""
  var zoomScaleAt:CGFloat = 1.0
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    fullScreenImage.image = imageToDisplay
    scrolViewContainer.delegate = self
    scrolViewContainer.minimumZoomScale = 1.0
    scrolViewContainer.maximumZoomScale = 5.0
    let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
    doubleTapGest.numberOfTapsRequired = 2
    scrolViewContainer.addGestureRecognizer(doubleTapGest)
    buttonControlView.layer.cornerRadius = 5
    setImage()
    }
  
  func setImage() {
    if let url = imageURL {
      AlamofireImage().getImage(imageUrl: url) { [weak self] image, _ in
        self?.fullScreenImage.image = image
      }
    }
  }
    
  @IBAction func zoomInTapped(_ sender: Any) {
    zoomScaleAt += 1.0
    scrolViewContainer.setZoomScale(zoomScaleAt, animated: true)
  }
  @IBAction func zoomOutTapped(_ sender: Any) {
    zoomScaleAt -= 1.0
    scrolViewContainer.setZoomScale(zoomScaleAt, animated: true)
  }
  
  @IBAction func backTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }

  @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
    if scrolViewContainer.zoomScale == 1 {
      scrolViewContainer.zoom(to: zoomRectForScale(scale: scrolViewContainer.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
    } else {
      scrolViewContainer.setZoomScale(1, animated: true)
    }
  }
  
  func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
    var zoomRect = CGRect.zero
    zoomRect.size.height = fullScreenImage.frame.size.height / scale
    zoomRect.size.width  = fullScreenImage.frame.size.width  / scale
    let newCenter = fullScreenImage.convert(center, from: scrolViewContainer)
    zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
    zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
    return zoomRect
  }
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return self.fullScreenImage
  }
}

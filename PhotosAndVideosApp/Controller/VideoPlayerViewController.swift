//
//  VideoPlayerViewController.swift
//  PhotosAndVideosApp
//
//  Created by Lavanya S Patil on 13/02/21.
//

import Foundation
import UIKit
import WebKit

class VideoPlayerViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    var video: Videos? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        if let strUrl: String = video?.video_files?.first?.link {
            let request = URLRequest.init(url: URL.init(string: strUrl)!)
            self.webView.load(request)
        }
        titleLabel.text = video?.user?.name
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

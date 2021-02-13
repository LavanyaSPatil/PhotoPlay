//
//  PhotoVideoThumbnailTableViewCell.swift
//  PhotosAndVideosApp
//
//  Created by Lavanya S Patil on 13/02/21.
//

import UIKit
import AlamofireImage

protocol UpdateTableViewDelegate {
    func updateModelData(cell: PhotoVideoThumbnailTableViewCell)
}


class PhotoVideoThumbnailTableViewCell: UITableViewCell {

    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var photographersImageView: UIImageView!
    @IBOutlet var favoriteBtn: UIButton!
    @IBOutlet var photographersNameLabel: UILabel!
    @IBOutlet var videoPlayerImageView: UIImageView!
    var photo: Photos?
    var video: Videos?
    var delegate: UpdateTableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        favoriteBtn.imageView?.image = nil
        thumbnailImageView.image = nil
        photo = nil
        video = nil
    }
    
    func configure(photo: Photos) {
        self.photo = photo
        videoPlayerImageView.isHidden = true
        if let url = photo.src?.tiny {
            AlamofireImage().getImage(imageUrl: url) { [weak self] image, _ in
                self?.thumbnailImageView.image = image
            }
        }
        favoriteBtn.setImage(photo.liked ?? true ? #imageLiteral(resourceName: "Favorite-home-select") : #imageLiteral(resourceName: "Facorite_home-deselet"), for: .normal)
        photographersNameLabel.text = photo.photographer
    }
    
    func configure(video: Videos) {
        self.video = video
        videoPlayerImageView.isHidden = false
        if let url = video.image {
            AlamofireImage().getImage(imageUrl: url) { [weak self] image, _ in
                self?.thumbnailImageView.image = image
            }
        }
        favoriteBtn.setImage(video.liked ?? true ? #imageLiteral(resourceName: "Favorite-home-select") : #imageLiteral(resourceName: "Facorite_home-deselet"), for: .normal)
        photographersNameLabel.text = video.user?.name
    }
    
    @IBAction func favBtnTapped(_ sender: Any) {
        switch NetworkManager.shared.listType {
        case .photos:
            favoriteBtn.setImage(!(photo?.liked)! ? #imageLiteral(resourceName: "Favorite-home-select") : #imageLiteral(resourceName: "Facorite_home-deselet"), for: .normal)
            if let index = NetworkManager.shared.photos.firstIndex(where: {$0.id == self.photo?.id}) {
                NetworkManager.shared.photos[index].liked = !((self.photo?.liked)!)
            }
            delegate?.updateModelData(cell: self)
        case .videos:
            favoriteBtn.setImage(!(video?.liked)! ? #imageLiteral(resourceName: "Favorite-home-select") : #imageLiteral(resourceName: "Facorite_home-deselet"), for: .normal)
            if let index = NetworkManager.shared.vidoes.firstIndex(where: {$0.id == self.video?.id}) {
                NetworkManager.shared.vidoes[index].liked = !((self.video?.liked)!)
            }
            delegate?.updateModelData(cell: self)
        case .favourites: break
        case .none: break

        }
    }
    
    func configure() {}
}

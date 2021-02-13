//
//  HomeViewModel.swift
//  PhotosAndVideosApp
//
//  Created by Lavanya S Patil on 13/02/21.
//

import Foundation

protocol UpdateDataViewDelegate {
    func update()
}

final class HomeViewModel {

    var photoList: PhotosBaseJson?
    var videoList: VideoJsonBase?
    var delegate: UpdateDataViewDelegate?
    
    func getPhotosList(searchStr: String) {
        
        NetworkManager().getPhotoSearch(searchStr: searchStr, completion: {[weak self] result in
            switch result {
            case .success(let model):
                self?.photoList = model
                if let list = model.photos {
                    NetworkManager.shared.photos.append(contentsOf: list)
                }
                self?.delegate?.update()
                case.failure(let error):
                print(error)
            }
        }
    )}
    
    func getVideoList(searchStr: String) {
        
        NetworkManager().getVideoSearch(searchStr: searchStr, completion: {[weak self] result in
            switch result {
            case .success(let model):
                self?.videoList = model
                if let list = model.videos {
                    NetworkManager.shared.vidoes.append(contentsOf: list)
                }
                self?.delegate?.update()
                case.failure(let error):
                print(error)
            }
        }
    )}
}

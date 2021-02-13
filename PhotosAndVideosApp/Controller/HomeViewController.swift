//
//  ViewController.swift
//  PhotosAndVideosApp
//
//  Created by Lavanya S Patil on 13/02/21.
//

import UIKit

enum ListType {
    case photos
    case videos
    case favourites
}

class HomeViewController: UIViewController {

    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var photoSelectionBtn: UIButton!
    @IBOutlet weak var photoSelectionView: UIView!
    @IBOutlet weak var videoSelectionBtn: UIButton!
    @IBOutlet weak var videoSelectionView: UIView!
    @IBOutlet weak var favSelectionBtn: UIButton!
    @IBOutlet weak var favSelectionView: UIView!
    
    let viewModel = HomeViewModel()
    var photos = [Photos]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBtnSelection()
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        viewModel.getPhotosList(searchStr: NetworkManager.shared.defaultSearchString)
        viewModel.delegate = self
        NetworkManager.shared.listType = .photos
        photoSelectionBtn.setTitleColor(tabSelectedColor, for: .normal)
        photoSelectionView.backgroundColor = tabSelectedColor

        let cell = UINib(nibName: "PhotoVideoThumbnailTableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "PhotoVideoThumbnailTableViewCell")
    }
    
    @IBAction func tabBtnTapped(_ sender: UIButton) {
        switch sender.tag {
        case 11:
            photoSelectionBtn.setTitleColor(tabSelectedColor, for: .normal)
            videoSelectionBtn.setTitleColor(tabDeselectedColor, for: .normal)
            favSelectionBtn.setTitleColor(tabDeselectedColor, for: .normal)
            photoSelectionView.backgroundColor = tabSelectedColor
            videoSelectionView.backgroundColor = UIColor.white
            favSelectionView.backgroundColor = UIColor.white
            NetworkManager.shared.listType = .photos
            if NetworkManager.shared.photos.isEmpty {
                self.viewModel.getPhotosList(searchStr: NetworkManager.shared.defaultSearchString)
            }else {
                self.tableView.reloadData()
            }
        case 12:
            photoSelectionBtn.setTitleColor(tabDeselectedColor, for: .normal)
            videoSelectionBtn.setTitleColor(tabSelectedColor, for: .normal)
            favSelectionBtn.setTitleColor(tabDeselectedColor, for: .normal)
            photoSelectionView.backgroundColor = UIColor.white
            videoSelectionView.backgroundColor = tabSelectedColor
            favSelectionView.backgroundColor = UIColor.white
            NetworkManager.shared.listType = .videos
            if NetworkManager.shared.vidoes.isEmpty {
                self.viewModel.getVideoList(searchStr: NetworkManager.shared.defaultSearchString)
            }else {
                self.tableView.reloadData()
            }
        case 13:
            photoSelectionBtn.setTitleColor(tabDeselectedColor, for: .normal)
            videoSelectionBtn.setTitleColor(tabDeselectedColor, for: .normal)
            favSelectionBtn.setTitleColor(tabSelectedColor, for: .normal)
            photoSelectionView.backgroundColor = UIColor.white
            videoSelectionView.backgroundColor = UIColor.white
            favSelectionView.backgroundColor = tabSelectedColor
            NetworkManager.shared.listType = .favourites
        default: break
        }
    }
    
    func setUpBtnSelection() {
        photoSelectionBtn.tag = 11
        videoSelectionBtn.tag = 12
        favSelectionBtn.tag = 13
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch NetworkManager.shared.listType {
        case .photos:
            return NetworkManager.shared.photos.count
        case .videos:
            return NetworkManager.shared.vidoes.count
        case .favourites:
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoVideoThumbnailTableViewCell", for: indexPath) as! PhotoVideoThumbnailTableViewCell
        cell.delegate = self
        switch NetworkManager.shared.listType {
        case .photos:
            cell.configure(photo: NetworkManager.shared.photos[indexPath.row])
        case .videos:
            cell.configure(video: NetworkManager.shared.vidoes[indexPath.row])
        case .favourites:
            cell.configure()
        case .none:
            cell.configure()
        }
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch NetworkManager.shared.listType {
        case .photos:
            if let photoDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoDetailViewController") as? PhotoDetailViewController {
                photoDetailVC.imageURL = NetworkManager.shared.photos[indexPath.row].src?.original ?? ""
                self.present(photoDetailVC, animated: true, completion: nil)
            }
        case .videos:
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VideoPlayerViewController") as VideoPlayerViewController
            vc.video = NetworkManager.shared.vidoes[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        case .favourites: break
        case .none:
            break
        }
    }
}

extension HomeViewController : UpdateDataViewDelegate, UpdateTableViewDelegate {
    func updateModelData(cell: PhotoVideoThumbnailTableViewCell) {
        self.tableView.beginUpdates()
        if let index = self.tableView.indexPath(for: cell) {
            self.tableView.reloadRows(at: [index], with: .none)
        }
        self.tableView.endUpdates()
    }
    
    func update() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if searchTextField.text != "" {
               //any task to perform
            NetworkManager.shared.vidoes.removeAll()
            NetworkManager.shared.photos.removeAll()
            NetworkManager.shared.defaultSearchString = searchTextField.text!
            switch NetworkManager.shared.listType {
            case .photos:
                
                viewModel.getPhotosList(searchStr: searchTextField.text ?? NetworkManager.shared.defaultSearchString)
            case .videos:
                viewModel.getVideoList(searchStr: searchTextField.text ?? NetworkManager.shared.defaultSearchString)
            default: break
            }
               textField.resignFirstResponder()
                searchTextField.text = ""
            }
            return true
        }
}




import Foundation

class NetworkManager: Request {

  var retryTimeInterval: TimeInterval = 30
  var retryLimit = 3
  let header = [
        "Authorization" : APIKey
    ]
    static let shared = NetworkManager()
    var photos = [Photos]()
    var photoPagecount: Int = 1
    var videoPageCount: Int = 1
    var vidoes = [Videos]()
    var listType: ListType? = .photos
    var defaultSearchString = "Animal Photos and Video"

//    
//    case .photoSearch(let searchStr, let pageCount):
//        return APIResource(URLString: "https://api.pexels.com/v1/search?query=\(searchStr)&per_page=\(pageCount)", method: .get, contentType: .json)
//    case .getVideoSearch(let searchStr, let pageCount):
//        return APIResource(URLString: "https://api.pexels.com/videos/search?query=\(searchStr)&per_page=\(pageCount)", method: .get, contentType: .json)
//    case .bannerImage:
//        return APIResource(URLString: "https://api.pexels.com/v1/curated?per_page=1", method: .get, contentType: .json)
//    
//    
    func getPhotoSearch(searchStr:String, completion: @escaping (Result<PhotosBaseJson, HandleError>) -> Void) {
        let queryItem = [
            "query" : "\(searchStr)",
            "per_page" : "20",
            "page" : "\(photoPagecount)"
        ]
        let config = ConfigureRequest(path: "/v1/search", params: nil, method: .get, queryDictionary:queryItem, host: "api.pexels.com")
    request(with: config.request, completion: completion)
  }
    
    func getVideoSearch(searchStr:String, completion: @escaping (Result<VideoJsonBase, HandleError>) -> Void) {
        let queryItem = [
            "query" : "\(searchStr)",
            "per_page" : "20",
            "page" : "\(videoPageCount)"
        ]
        let config = ConfigureRequest(path: "/videos/search", params: nil, method: .get, queryDictionary:queryItem, host: "api.pexels.com")
    request(with: config.request, completion: completion)
  }
}

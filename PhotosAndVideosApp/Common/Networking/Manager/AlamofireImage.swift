
import Alamofire
import AlamofireImage
import UIKit

enum CacheConstants: Double {
    case megaBytes = 1_048_576.0
    case timeToLive = 60.0
    case cacheCountLimit = 10
    case cacheTotalCostLimit = 50_000_000
    case memoryCapacity = 100_000_000
    case preferredMemory = 60_000_000
}

enum CacheNames: NSString {
    case watchLanding = "WatchModelData"
    case showDetail = "ShowDetailData"
    case showList = "ShowListData"
    case shopDetail = "ShopDetailData"
    case shopLanding = "ShopData"
    case cacheExpiry = "Expiry"
    case talentList = "TalentListData"
    case myList = "MylistData"
    case talentDetail = "TalentDetail"
    case episodeDetail = "EpisodeDetail"
}

class AlamofireImage {

  let imageCache = AutoPurgingImageCache(
    memoryCapacity: UInt64(CacheConstants.memoryCapacity.rawValue),
    preferredMemoryUsageAfterPurge: UInt64(CacheConstants.preferredMemory.rawValue)
  )

  private static let imageCacheManager = AlamofireImage()

  class func shared() -> AlamofireImage {
    return imageCacheManager
  }

    func getImage(imageUrl: String, completion: @escaping(_ image: UIImage?, _ error: NSError?) -> Void) {
        DispatchQueue.global().async {
            if let cachedImage = AlamofireImage.imageCacheManager.imageCache.image(withIdentifier: imageUrl) {
                if let cachedTime = UserDefaults.standard.value(forKey: CacheNames.cacheExpiry.rawValue as String) as? Date {
                    let timeInterval = Date().timeIntervalSince(cachedTime)
                    if timeInterval < CacheConstants.timeToLive.rawValue {
                        // Time expiry not reached, return cached image
                        DispatchQueue.main.async {
                            completion(cachedImage, NSError())
                        }
                    } else {
                        // Time expired. Evict all images and request again.
                        AlamofireImage.imageCacheManager.imageCache.removeAllImages()
                        self.downloadImageForUrlString(imageUrl, completion: completion)
                    }
                } else {
                    self.downloadImageForUrlString(imageUrl, completion: completion)
                }
            } else {
                // First time download
                UserDefaults.standard.set(Date(), forKey: CacheNames.cacheExpiry.rawValue as String)
                self.downloadImageForUrlString(imageUrl, completion: completion)
            }
        }
    }
}

private extension AlamofireImage {

  func requestImage(requestUrlString: String, completion: @escaping(_ image: UIImage?, _ error: NSError?) -> Void) {
    AF.request(requestUrlString, method: .get).response { response in
      switch response.result {
      case .success(let responseData):
        guard let responseData = responseData else {
          completion(UIImage(named: "placeholder"), NSError())
          return
        }
        let image = UIImage(data: responseData, scale: 1)
        if let image = image {
          completion(image, NSError())
        } else {
          completion(UIImage(named: "placeholder"), NSError())
        }
      case .failure(let error) :
        print("error--->", error)
        completion(UIImage(named: "placeholder"), NSError())
      }
    }
  }

    func downloadImageForUrlString(_ urlString: String, completion: @escaping(_ image: UIImage?, _ error: NSError?) -> Void) {
        requestImage(requestUrlString: urlString) {  imageData, error in
            if let image = imageData {
                AlamofireImage.imageCacheManager.imageCache.add(image, withIdentifier: urlString)
                DispatchQueue.main.async {
                    completion(image, error)
                }
            }
        }
    }

}

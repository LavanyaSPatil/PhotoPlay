//
//  NetworkManager.swift
//  WandApp
//
//  Created by Guruprasad Bhat on 07/06/18.
//  Copyright © 2018 PRO Unlimited, Inc. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class NetworkManager {
    
    static let shared = NetworkManager()
    
    var session: Alamofire.SessionManager
    
    fileprivate var defaultConfiguration: URLSessionConfiguration! {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = nil
       // config.tlsMinimumSupportedProtocol = SSLProtocol.tlsProtocol12
        return config
    }
    
    private init() {
        //session = SessionManager(configuration: defaultConfiguration, serverTrustPolicyManager: CustomServerTrustPolicyManager(policies: [:], isServerTrusted: isServerTrusted))
        session = Alamofire.SessionManager(configuration: .default, delegate: AppSessionDelegate(), serverTrustPolicyManager: nil)
        session.retrier = APIRequestRetrier()
        UIImageView.af_sharedImageDownloader = imgDownloader()
    }
    
    var isServerTrusted: Bool = SSLHandler.shared.canConnectToServer {
        didSet {
            session = SessionManager(configuration: defaultConfiguration, serverTrustPolicyManager: CustomServerTrustPolicyManager(policies: [:], isServerTrusted: isServerTrusted))
            session.retrier = APIRequestRetrier()
            UIImageView.af_sharedImageDownloader = imgDownloader()
        }
    }
    
    private func imgDownloader() -> ImageDownloader {
        let imgSession = SessionManager(configuration: ImageDownloader.defaultURLSessionConfiguration(),
                                        serverTrustPolicyManager: CustomServerTrustPolicyManager(policies: [:], isServerTrusted: isServerTrusted))
        return ImageDownloader(sessionManager: imgSession)
    }
    
    private let ntwReachabilityMgr = NetworkReachabilityManager()
    var isServerReachable: Bool {
        print("network reachability check")
        print(ntwReachabilityMgr?.isReachable ?? false)
        if ntwReachabilityMgr?.isReachable == false {
            APP_BASEVIEWCONTROLLER?.showAlert("Network Error", message: "check")
        }
        return ntwReachabilityMgr?.isReachable ?? false
    }
}

class APIRequestRetrier: RequestRetrier {
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        
        var shouldRetry = false
        var delay = 0.0
        guard (error as NSError).code == -1001 else {
            completion(shouldRetry, delay)
            return
        }
        
        if request.retryCount < 2 {
            shouldRetry = true
            delay = 2.0 + (Double(request.retryCount) * 2.0)
            
            print("===================================================================")
            print("Request retry!")
            print(request.request?.url?.absoluteString ?? "")
            print("Retry count = \(request.retryCount + 1) After a delay = \(delay)")
            print("===================================================================")
        }
        
        completion(shouldRetry, delay)
    }
}

class AppSessionDelegate: SessionDelegate {

}


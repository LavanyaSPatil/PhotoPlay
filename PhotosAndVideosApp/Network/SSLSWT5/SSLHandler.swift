//
//  SSLHandler.swift
//  WandApp
//
//  Created by Namitha J on 12/01/18.
//  Copyright © 2018 PRO Unlimited, Inc. All rights reserved.
//

import Foundation
import Alamofire

typealias VoidCompletion = () -> Void

class SSLHandler {
    
    private init () {}
    static let shared = SSLHandler()
    
    var allowOnce: Bool?
    var abort = false
    var noSSLError: Bool?
    
    var canConnectToServer: Bool {
        guard abort == false else {
            ///If abort is selected then we need to show alert again and again, before connecting.
            return false
        }
        if let noError = noSSLError, noError == true {
            ///SSL checking done once and there is no ssl error.
            return true
        }
        let allowAlways: Bool = UserPreference.value(forKey: UserPreferenceKey.alwaysAllowNonSecureLoads) ?? false
        let once = self.allowOnce ?? false
        
        if allowAlways || once { 
            return true
        }
        
        return false
    }
    
    ///This array will hold closures to be called after SSL checking.
    var listioners: [VoidCompletion]?
    
    /**
     Adds a closure to listener array.
     - parameter listioner: Closure block
    */
    func addCompletion(listioner: VoidCompletion?) {
        if nil == self.listioners { self.listioners = [VoidCompletion]() }
        if let listion = listioner {
            self.listioners?.append(listion)
        }
    }
    
    /**
     Executes all listeninbg closures. And after execution removes all closures from the array.
    */
    func executeListioningFunctions() {
        if let items = self.listioners {
            for item in items {
                item()
            }
            self.listioners?.removeAll()
        }
    }
    
    enum ConnectionOption {
        case allowAlways
        case allowOnce
        case abort
    }
    
    func updateUserChoice(option: ConnectionOption) {
        switch option {
        case .allowAlways:
            ///User tapped Allow Always
            UserPreference.set(value: true, forKey: UserPreferenceKey.alwaysAllowNonSecureLoads)
            NetworkManager.shared.isServerTrusted = true
            self.abort = false
            ///We will execute all pending web requests
            self.executeListioningFunctions()
        case .allowOnce:
            ///User tapped Allow Once
            UserPreference.set(value: false, forKey: UserPreferenceKey.alwaysAllowNonSecureLoads)
            NetworkManager.shared.isServerTrusted = true
            self.abort = false
            self.allowOnce = true
            ///We will execute all pending web requests
            self.executeListioningFunctions()
        case .abort:
            UserPreference.set(value: false, forKey: UserPreferenceKey.alwaysAllowNonSecureLoads)
            NetworkManager.shared.isServerTrusted = false
            self.abort = true
            self.listioners?.removeAll()
        }
    }
    
    func authenticateSSLCertificate(completion: @escaping (Bool, Error?) -> Void) {
        if let allowAlways: Bool = UserPreference.value(forKey: UserPreferenceKey.alwaysAllowNonSecureLoads), allowAlways == true {
            NetworkManager.shared.isServerTrusted = true
             completion(true, nil)
        } else {
            
            let URLString = kBaseURLSWFT5 + API.versionAPI.rawValue
            let request = URLRequest.init(url: URL(string: URLString)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: .infinity)
            let task = URLSession(configuration: .default).dataTask(with: request, completionHandler: {
                data, response, error in
                guard let responseError = error else {
                    ///No SSL problem in the current server.
                    print("No SSL problem")
                    self.noSSLError = true
                    NetworkManager.shared.isServerTrusted = true
                    ///Execute pending web requests.
                    self.executeListioningFunctions()
                    completion(true, nil)
                    return
                }
                
                DispatchQueue.main.async {
                    ///There is some error. Now check for is it SSL error?
                    if self.isThereSSLError(error: responseError) {
                        completion(false, responseError)
                    } else {
                        ///Error is not an SSL error so we continue executing pending requests.
                        self.noSSLError = true
                        NetworkManager.shared.isServerTrusted = true
                        self.executeListioningFunctions()
                        completion(false, nil)
                    }
                }
            })
            task.resume()
        }
    }

    /**
     This function will check whether given error is any SSL specific error.
     - parameter error: Error to be checked.
     - Returns: `true` if error is SSL error else `false`
    */
    func isThereSSLError(error: Error) -> Bool {
        let error = error as NSError
        switch error.code {
        case SSLError.cerificateNotYetValid.rawValue: return true
        case SSLError.certificateHasBadDate.rawValue: return true
        case SSLError.certificateRejected.rawValue: return true
        case SSLError.certificateRequired.rawValue: return true
        case SSLError.certificateUntrusted.rawValue: return true
        case SSLError.certificateWithUnkownRoot.rawValue: return true
        case SSLError.secureConnectionFailed.rawValue: return true
        case SSLError.unableToLoadFromNetwork.rawValue: return true
        default:
            return false
        }
    }
}

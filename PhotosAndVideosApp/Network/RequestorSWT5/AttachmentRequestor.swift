//
//  AttachmentRequestor.swift
//  WandApp
//
//  Created by Guruprasad Bhat on 03/04/18.
//  Copyright © 2018 PRO Unlimited, Inc. All rights reserved.
//

import Foundation

struct Model: Codable {
    
}

class AttachmentRequestor: BaseRequestor {
    
    init(path: String) {
        let res = APIResource(URLString: path, method: RequestMethod.get, pHashFrom: PHashInput.dtm)
        super.init(resource: res)
    }
    
    func creatRequest() throws -> URLRequest? {
        
        if NetworkManager.shared.isServerReachable {
            guard let url = URL(string: self.apiResource.urlString) else {return nil}
            
            var urlrequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 180.0)
            if let headers = self.httpHeaders {
                for (key, value) in headers {
                    urlrequest.setValue(value, forHTTPHeaderField: key)
                }
            }
            urlrequest.setValue("true", forHTTPHeaderField: "HttpOnly")
            return urlrequest
        } else {
              APP_BASEVIEWCONTROLLER?.showAlert("Network Error", message: "check")
            throw APIError.noInternetConnection
        }
    }
}

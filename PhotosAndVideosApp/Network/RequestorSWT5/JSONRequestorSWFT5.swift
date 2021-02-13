//
//  JSONRequestor.swift
//  WandApp
//
//  Created by Guruprasad Bhat on 27/11/17.
//  Copyright © 2017 PRO Unlimited, Inc. All rights reserved.
//

import Foundation
import Alamofire

class JSONRequestorSWFT5: BaseRequestor {
    
    override func sendRequest<T>(completion: ((DataResult<T>) -> Void)?) -> DataRequestID where T : Decodable {
        
        if NetworkManager.shared.isServerReachable {
            let req = self.sendRequest()?.responseJSON(queue: DispatchQueue.global(), completionHandler: { (response) in
                
                self.printResponse(response)
                let result: DataResult<T>
                do {
                    let parseResult: APIResponse<T> = try self.parseJSON(response: response)
                    result = DataResult.success(parseResult)
                    completion?(result)
                } catch {
                    let apiError: APIError = (error as? APIError) ?? APIError.somethingWentWrong
                    result = DataResult.failure(apiError)
                    
                    /// remove auto renewal of access token,
                    ///so for both error codes we are showing session expire message.
                    switch apiError {
                    case .requestCancelled:
                        //Request is cancelled
                        print("===================================================================")
                        print("Request cancelled!!!")
                        print("===================================================================\n\n")
                        
                    case .invalidAccessToken,
                         .sessionExpired:
                        /**
                         1. If error is session expiry or invalid access token. then we post session expiry notification. Our AppCoordinator will observe for this, and handle the session expiry.
                         2. Also check for the request of sessionExpiry in completion. If it required we pass session expiry error in completion.
                         */
                        
                        print("InValid Session")
                        NotificationCenter.default.post(name: NSNotification.Name(sessionExpiryNotificationName), object: nil)
                        if let shouldReturn = self.apiResource?.shouldReturnSessionExpiry, shouldReturn {
                            completion?(result)
                        }
                    default:
                        ///Any other error we pass in completion.
                        completion?(result)
                    }
                }
                
            })
            return self.generateTaskId(forReq: req!)
        } else {
              APP_BASEVIEWCONTROLLER?.showAlert("Network Error", message: "check")
            completion?(DataResult.failure(APIError.noInternetConnection))
            return ""
        }
    }
    
    /**
     This validates the data and error with respect to JSON format.
     1. Data should not be nil
     2. Data should be a `Dictionary`.
     3. There should not be a sessionExpiry, invalidAccessToken, or invalidRequest status codes.
     4. There should not be any error.
     
     - parameter data: resposne data
     - parameter error: response error
     - Returns: A *tuple* with success flag and optional APIError
     */
    override func validate(data: Any?, error: Error?) -> (success: Bool, error: APIError?) {
        let validation = super.validate(data: data, error: error)
        
        guard validation.success, validation.error == nil else {
            return validation
        }
        
        //Some JSON specific validation here
        guard let json = data as? JSONDictionarySWFT5 else {
            //Not a json dictionary
            return (false, APIError.invalidResponse)
        }
        
        var status: Int = NSNotFound
        if let cd = json["status"] as? Int {
            status = cd
        } else if let cdStr = json["status"] as? String, let cd = Int(cdStr) {
            status = cd
        }
        
        guard status != APIStatusCode.invalidAccessToken.rawValue else {
            //invalid access token
            return (false, APIError.invalidAccessToken)
        }
        
        guard status != APIStatusCode.sessionExpired.rawValue else {
            //invalid session
            return (false, APIError.sessionExpired)
        }
        
        guard status != APIStatusCode.invalidRequest.rawValue else {
            //request is invalid
            return (false, APIError.invalidRequest)
        }
        
        if let respkey = self.apiResource?.responseKeyPath {
            guard (json as AnyObject).value(forKeyPath: respkey) != nil else {
                //data missing at required key path
                return (false, APIError.invalidResponse)
            }
        }
        
        return (true, nil)
    }
    
    /**
     Creates the Model by parsing the response JSON.
     If there is any validation error or decoding error `APIError` is thrown.
     
     - Returns: `APIResponse` encapsulating the status code, data model & response headers.
    */
    func parseJSON<T: Decodable>(response: DataResponse<Any>) throws -> APIResponse<T> {
        
        var parsedModel: APIResponse<T>
        
        let validation = self.validate(data: response.value, error: response.error)
        guard validation.success, validation.error == nil else {
            //return (nil, validation.error)
            throw validation.error!
        }
        var json = response.value
        
        var statusCode = NSNotFound
        
        ///Getting status code from the response.
        if let sCode = (json as AnyObject).value(forKeyPath: "s") as? Int {
            if sCode == 1 {
                statusCode = 200
            }else {
                statusCode = sCode
            }
        } else if let codeStr = (json as AnyObject).value(forKeyPath: "s") as? String, let sCode = Int(codeStr) {
                if sCode == 1 {
                       statusCode = 200
                   }else {
                       statusCode = sCode
                   }
        }
        
        ///Getting the data from required key paths
        if let keyPath = self.apiResource?.responseKeyPath, let nestedJson = (json as AnyObject).value(forKeyPath: keyPath) {
            json = nestedJson as? Data
        }
        
        let headers = response.response?.allHeaderFields
        
        if T.self == CODE.self {
            ///If API is requested just to return status code. we don't do decoding.
            parsedModel = APIResponse<T>(statusCode: statusCode, data: nil, responseHeaders: headers)
        } else {
            var obj: T?, parseError: APIError?
            do {
                let data = try JSONSerialization.data(withJSONObject: json as Any)
                ///Actual model creation happens here.
                obj = try self.decoder.decode(T.self, from: data)
            } catch {
                print(error)
                ///Some decoding error occured.
                parseError = APIError.parsingError
            }
            
            ///Some API returns just status code in some scenarios.
            ///to handle that we check for parsed object and status code.
            if obj == nil, statusCode != NSNotFound {
                ///If object is nil and contain valid status code. then we need to pass success response in completion.
                parsedModel = APIResponse<T>(statusCode: statusCode, data: nil, responseHeaders: headers)
            } else if let model = obj {
                parsedModel = APIResponse<T>(statusCode: statusCode, data: model, responseHeaders: headers)
            } else {
                //throwing parse error
                throw parseError ?? APIError.parsingError
            }
        }
        return parsedModel
    }
}

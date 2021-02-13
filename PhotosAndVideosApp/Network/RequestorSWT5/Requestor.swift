//
//  Requestor.swift
//  WandApp
//
//  Created by Guruprasad Bhat on 27/11/17.
//  Copyright © 2017 PRO Unlimited, Inc. All rights reserved.
//

import Foundation
import Alamofire

public typealias DataRequestID = String

public typealias APICompletion<D: Decodable> = ((DataResult<D>) -> Void)
public let sessionExpiryNotificationName = "LoginSessionExpired"

class BaseRequestor {
    
    let apiResource: APIResource!
    let decoder = JSONDecoder()

//    static var sessionManager = SessionManager(
//        serverTrustPolicyManager: CustomServerTrustPolicyManager(policies: [:], isServerTrusted: BaseRequestor.isServerTrusted
//        )
//    )
//    static var isServerTrusted: Bool = SSLHandler.shared.canConnectToServer {
//        didSet {
//            sessionManager = SessionManager(
//                serverTrustPolicyManager: CustomServerTrustPolicyManager(policies: [:], isServerTrusted: BaseRequestor.isServerTrusted
//            ))
//        }
//    }
  
    init(resource: APIResource?) {
        self.apiResource = resource
    }
    
    /**
    Creates a `DataRequest` using Alamofire's request method.
    
    - Returns: `DataRequest` created by Alamofire.
    */
    internal func sendRequest() -> DataRequest? {
    
        let request = NetworkManager.shared.session.request(apiResource.urlString, method: self.httpMethod, parameters: apiResource.parameter, encoding: parameterEncodingForAPI(resource: apiResource), headers: self.httpHeaders).validate()
        ///Printing it out request details.
        self.printRequestDetails(request, dataParameters: apiResource.parameter)
        return request
    }
    
    /**
     It will create network request to get the data from specified URL
     ## Note ##
     This is a generic requestor method. Here we need to specify data type we requesting for. And in completion block this will return same type of data.
     
     - Retruns: unique data request ID of type `String`
    */
    func sendRequest<T: Decodable>(completion: APICompletion<T>?) -> DataRequestID {
        
        ///Network connection checking.
        if NetworkManager.shared.isServerReachable {
            guard let request = self.sendRequest() else { return "invalid request" }
            let dataReq = request.response { (response) in
                
                let validation = self.validate(data: response.data, error: response.error)
                let result: DataResult<T>
                if validation.success, let data = response.data as? T {
                    result = DataResult.success(APIResponse<T>(statusCode: 200, data: data, responseHeaders: response.response?.allHeaderFields))
                } else {
                    result = DataResult.failure(validation.error ?? APIError.somethingWentWrong)
                }
                completion?(result)
            }
            return self.generateTaskId(forReq: dataReq)
        } else {
            APP_BASEVIEWCONTROLLER?.showAlert("Network Error", message: "check")
            completion?(DataResult.failure(APIError.noInternetConnection))
            return ""
        }
    }
    
    final var httpMethod: HTTPMethod {
        get {
            return HTTPMethod(rawValue: self.apiResource.method.rawValue) ?? HTTPMethod.get
        }
    }
    
    final var httpHeaders: [String : String]? {
        get {
            
            var headers: [String : String] = [:]
            
            ///Here we add common headers first
            self.setPHashForAPIRequest(&headers)
            
            if case .json = apiResource.contentType {
                /**
                 Alamofire will set Content-Type depending upon ParameterEncoding.
                 But for some of our API require application/json but doesn't have request parameter's.
                 Alamofire will set content type if request parameters are present. So we are setting content type for json specifically. By default it will be urlencoded only.
                */
                headers["Content-Type"] = "application/json"
            }
//            if let uId = UserSession.shared.loginUserId {
//                headers["user_id"] = "\(uId)"
//            }
//            if let deviceId : String = UserPreference.value(forKey: UserPreferenceKey.deviceId) {
//                headers["device_id"] = deviceId
//            }
//            if let accessToken = UserSession.shared.accessToken {
//                headers["access_token"] = accessToken
//            }
//
            ///Now we are adding any API specific headers.
            if let customHeader = apiResource.customHeader {
                for (key, value) in customHeader {
                    headers[key] = value as? String
                }
            }
            return headers
        }
    }
    
    /**
     pHash generation for the API request.
     pHash will be generated either from full request parameters or dtm.
     
     - parameters headers: inout dictionary to which pHash will be set.
    */
    internal func setPHashForAPIRequest(_ headers: inout [String : String]) {
        
//        guard let pKey = UserSession.shared.pKey else {
//            ///pKey is important for generating pHash.
//            return
//        }
        var phashDict = [String:String]()
        var inStr: String?
     //   let dtmStr = Date.dtmString
        ///First we check for how to generate pHash. either using dtm or full request parameters.
        
        if case .dtm = self.requiredPHashType {
            ///pHash should be generated using dtm only.
//            inStr = dtmStr
//            phashDict["dtm"] = dtmStr
            
        } else {
            
            guard let parameters = self.apiResource.parameter else { return }
            /**
             For generating pHash data required to be in same way as it goes in request.
             So we are preparing the data similar way as Alamofire does.
             */
            switch self.apiResource.contentType {
            case .urlEncoded:
                let encoding = URLEncoding.default
                
                var components: [(String, String)] = []
                
                for key in parameters.keys.sorted(by: <) {
                    let value = parameters[key]!
                    components += encoding.queryComponents(fromKey: key, value: value)
                }
                inStr =  components.map { "\($0)=\($1)" }.joined(separator: "&")
                
            default:
                let encoding = JSONEncoding.default
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: encoding.options)
                    inStr = String(data: jsonData, encoding: String.Encoding.utf8)
                } catch { print(error) }
            }
            
        }
        
        guard let bodyStr = inStr else { return }
        
        //migrated to swift
 /*   LSP     let pHash = bodyStr.digest(.sha512, key: pKey)

        //NetworkUtility.hashedBase64Value(ofData: bodyStr, withKey: pKey) else { return }
        
        phashDict["pHash"] = pHash
        
        for (key, value) in phashDict {
            headers[key] = value
        } LSP */
    }
    
    fileprivate var requiredPHashType: PHashInput {
        //If during request itself dtm is mentioned returning dtm.
        guard self.apiResource.pHashInput != .dtm else {
            return .dtm
        }
        //If request is get method then its always dtm based irresptive of parameters.
        guard self.apiResource.method != .get else {
            return .dtm
        }
        //If there is no parameters at all then its dtm based.
        guard let parameters = self.apiResource.parameter, parameters.count > 0 else {
            return .dtm
        }
        return .requestParams
    }
    
    /**
     This will return Parameter encoding required for Alamofire.
     - parameter resource: API resource.
     - Returns: ParameterEncoding required for API request.
    */
    final func parameterEncodingForAPI(resource: APIResource) -> ParameterEncoding {
        switch resource.contentType {
        case .json:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    /**
     Generates UUID. And saves the URLSessionTask for the generated UUID.
     This UUID string can be used for cancelling the URLSessionTask.
     - parameter req: Alamofire request.
     - Returns: UUID string.
    */
    final func generateTaskId(forReq req: Request) -> String {
        let uniqueId = UUID().uuidString
        RequestManager.shared.setTask(req.task, forKey: uniqueId)
        return uniqueId
    }
    
    /**
     Validates the data and error in basic level.
     1. Data should not be nil
     2. There should not be any error.
     
     - parameter data: resposne data
     - parameter error: response error
     - Returns: A *tuple* with success flag and optional APIError
    */
    func validate(data: Any?, error: Error?) -> (success: Bool, error: APIError?) {
        
        ///Here just basic validation checking data is nil or not and error is present.
        var validationError: APIError?
        if data == nil {
            validationError = APIError.invalidResponse
        }
        if error != nil {
            let code = (error as NSError?)?.code
            let msg = (error as NSError?)?.localizedDescription
            if ((code ?? 0) == -999) && ((msg ?? "").lowercased() == "cancelled") {
                validationError = APIError.requestCancelled
            } else {
                validationError = APIError.generalError(code: code, message: msg)
            }
        }
        let status = (validationError == nil) ? true : false
        return (status, validationError)
    }
    

    
    func printRequestDetails(_ request: Request, dataParameters: Any?) {
        
        print("===================================================================")
        print("Request: \n")
        print("Method       = ", request.request?.httpMethod ?? "NA")
        print("URL          = " , request.request?.url ?? "NA")
        print("Headers      = ", request.request?.allHTTPHeaderFields ?? "NA")
        print("parameters   = ", dataParameters ?? "NA")
        print("DebugDescription\n")
        print(request.debugDescription)
        print("===================================================================\n\n")
        
    }
    
    func printResponse(_ response: DataResponse<Any>)  {
        print("===================================================================")
        print("Response:")
        print("DebugDescription")
        print(response.debugDescription)
        print("===================================================================\n\n")
    }
    
    deinit {
        print("Base requestor deinit called")
    }
}





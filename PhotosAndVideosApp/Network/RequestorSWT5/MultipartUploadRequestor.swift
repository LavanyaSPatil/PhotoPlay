//
//  MultipartUploadRequestor.swift
//  WandApp
//
//  Created by Guruprasad Bhat on 28/11/17.
//  Copyright © 2017 PRO Unlimited, Inc. All rights reserved.
//

import Foundation
import Alamofire

class MultipartUploadRequestor: JSONRequestorSWFT5 {
    /**
     Multipart API requestor. It will create and execute the multipart upload request.
     - parameter progress: Closure to be called for progress indication.
     - parameter completion; Closure to be called once API request finishes.
     
     - Returns: Unique data request ID of type `String`
    */
    func sendMultipartRequest<T>(progress: ((Progress) -> Void)? = nil, completion: ((DataResult<T>) -> Void)?) -> DataRequestID where T : Decodable {
        
        if NetworkManager.shared.isServerReachable {
            ///First we create once unique id.
            ///In multipart we receive URLSessionTask in encoding completion. But we need to return request id at the end.
            ///So we create task ID and return it but later we map the session task with this id.
            let taskId = UUID().uuidString
            
            NetworkManager.shared.session.upload(multipartFormData: { (formData) in
                //set the form data
                if let data = self.apiResource.formData {
                    self.appendData(data, toMultipartFormData: formData)
                }
                
            }, to: apiResource.urlString, method: self.httpMethod, headers: self.httpHeaders) { (encodingResult) in
                
                switch encodingResult {
                case .success(let uploadRequest, _, _):
                    
                    self.printRequestDetails(uploadRequest, dataParameters: self.apiResource.formData)
                    ///Mapping URLSessionTask with unique task ID string.
                    RequestManager.shared.setTask(uploadRequest.task, forKey: taskId)
                    
                    if let progressHandler = progress {
                        ///Setting the progress block to upload request.
                        uploadRequest.uploadProgress(closure: progressHandler)
                    }
                    
                    uploadRequest.responseJSON(queue: DispatchQueue.global(), completionHandler: { (response) in
                        
                        self.printResponse(response)
                        let result: DataResult<T>
                        do {
                            let parseResult: APIResponse<T> = try self.parseJSON(response: response)
                            result = DataResult.success(parseResult)
                            completion?(result)
                        } catch {
                            let parseError: APIError = (error as? APIError) ?? APIError.somethingWentWrong
                            result = DataResult.failure(parseError)
                            
                            /// remove auto renewal of access token,
                            ///so for both error codes we are showing session expire message.
                            switch parseError {
                            case .requestCancelled:
                                //Request is cancelled
                                print("===================================================================")
                                print("Multipart Request cancelled!!!")
                                print("===================================================================\n\n")
                                
                            case .invalidAccessToken,
                                 .sessionExpired:
                                /**
                                 1. If error is session expiry or invalid access token. then we post session expiry notification. Our AppCoordinator will observe for this, and handle the session expiry.
                                 2. Also check for the request of sessionExpiry in completion. If it required we pass session expiry error in completion.
                                 */
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
                    
                case .failure(let error):
                    ///Failed to upload request
                    let code = (error as NSError).code
                    let msg = (error as NSError).localizedDescription
                    completion?(DataResult.failure(APIError.generalError(code: code, message: msg)))
                }
            }
            
            return taskId
        } else {
              APP_BASEVIEWCONTROLLER?.showAlert("Network Error", message: "check")
            completion?(DataResult.failure(APIError.noInternetConnection))
            return ""
        }
    }
    
    /**
     Appends the request parameters and attachment data to `MultipartFormData`
     
     - parameter input: `APIResource.FormData` API request data.
     - parameter toMultipartFormData: `MultipartFormData` form data to which data needs to be added.
    */
    private func appendData(_ input: APIResource.FormData, toMultipartFormData: MultipartFormData) {
        
        //first appending attachment data e.g. image data
        if let fileDataList = input.fileAttachments {
            for fileData in fileDataList {
                if let data = fileData.data, let fname = fileData.fileName, let mime = fileData.mimeType {
                    toMultipartFormData.append(data, withName: fileData.keyName, fileName: fname, mimeType: mime)
                }
            }
        }
        //Rest of the request parameters.
        for (keyname, value) in input.otherParameter {
            toMultipartFormData.append(value, withName: keyname)
        }
    }
}


//
//  RequestManager.swift
//  WandApp
//
//  Created by Guruprasad Bhat on 28/11/17.
//  Copyright © 2017 PRO Unlimited, Inc. All rights reserved.
//

import Foundation

class RequestManager {
    
    static let shared = RequestManager()
    
    ///Map table for holding URLSessionTask's, Key will be request ID string.
    private var taskDictionary = NSMapTable<NSString, URLSessionTask>.strongToWeakObjects()
    ///Array to hold `DataResource`'s which has to be re-executed.
    private var retryDataResources: [DataResourceRetrier] = [DataResourceRetrier]()
    
    /**
     Adds URLSessionTask to the map table
    */
    func setTask(_ task: URLSessionTask?, forKey key: String) {
        self.taskDictionary.setObject(task, forKey: key as NSString)
    }
    
    /**
     Gives the URLSessionTask for the specified request ID string.
    */
    private func task(forKey key: String) -> URLSessionTask? {
        return self.taskDictionary.object(forKey: key as NSString)
    }
    
    private func removeTask(forKey key: String) {
        self.taskDictionary.removeObject(forKey: key as NSString)
    }
    
    /**
     Cancels all the URLSessionTask's.
    */
    func cancelAllRequests() {
        
        if let objects = self.taskDictionary.objectEnumerator() {
            for task in objects {
                (task as? URLSessionTask)?.cancel()
            }
        }
    }
    
    /**
     Cancels URLSessionTask's for the specified request ID's
     
     - parameter requestIds: Request ID array.
    */
    func cancelRequests(_ requestIds: [String]) {
        for requestId in requestIds {
            if let task = self.task(forKey: requestId) {
                task.cancel()
                self.removeTask(forKey: requestId)
            }
        }
    }
    
    // MARK: Request retry
    /**
     Adds data resource to retrier array
    */
    func appendPendingDataResourceRequest(_ req: DataResourceRetrier) {
        print("Adding data resource to pending list")
        self.retryDataResources.append(req)
    }
    
    /**
     Executes web requests queued in retrier array
     After executing removes all data resource from the array.
    */
    func executePendingDataResourceRequests() {
        for resource in self.retryDataResources {
            resource.retryWebFetcher()
        }
        self.retryDataResources.removeAll()
    }
    
    /**
     Completes the data request with error for all requests queued in retrier array
     After executing removes all data resource from the array.
     */
    func clearPendingRequestQueue() {
        self.retryDataResources.forEach { (dataResource) in
            dataResource.clearRequest()
        }
        self.retryDataResources.removeAll()
    }
    
    func flushRequestQueue() {
        self.retryDataResources.removeAll()
    }
    
    deinit {
        cancelAllRequests()
    }
}

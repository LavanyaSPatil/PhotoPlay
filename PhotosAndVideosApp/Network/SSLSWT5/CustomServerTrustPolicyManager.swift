//
//  CustomServerTrustPolicyManager.swift
//  WandApp
//
//  Created by Namitha J on 11/01/18.
//  Copyright © 2018 PRO Unlimited, Inc. All rights reserved.
//

import Foundation
import Alamofire

class CustomServerTrustPolicyManager: ServerTrustPolicyManager {
    var isServerTrusted = true
    
    public init(policies: [String: ServerTrustPolicy], isServerTrusted: Bool) {
        super.init(policies: policies)
        self.isServerTrusted = isServerTrusted
    }
    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        // Check if we have a policy already defined, otherwise just kill the connection
        if let policy = super.serverTrustPolicy(forHost: host) {
            print(policy)
            return policy
        } else {
            return .customEvaluation({ (_, hostName) -> Bool in
                guard NetworkManager.shared.isServerTrusted else { return false}
                
                let result = kBaseURLSWFT5.contains(hostName)
                return result
            })
        }
    }
}

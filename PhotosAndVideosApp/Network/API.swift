//
//  API.swift
//  WandApp
//
//  Created by Guruprasad on 11/2/17.
//  Copyright © 2017 PRO Unlimited, Inc. All rights reserved.
//

import Foundation

// MARK: -Server

enum ServerEnvironment {
    case live, development
    
    var baseURL: String {
        switch self {
        // Live production server
        case .live:
            return "https://m.prowand.pro-unlimited.com"
            
        // Servers used during development and testing
        case .development:
            return "https://implementations.prounlimited.com" //"https://m.prodtest2.prounlimited.com"  //192.1.1.154:8080"
     
        }
    }
}

#if PRODUCTION
    let currentEnvironmentSWFT5: ServerEnvironment = .live
#else
    let currentEnvironmentSWFT5: ServerEnvironment = .development
#endif

// MARK: -Server Base URL

/// Server base URL string.
public let kBaseURLSWFT5 = currentEnvironmentSWFT5.baseURL

// MARK: -API's list


public let kAPICommonPrefix = "/pro.mobile" //"/supplier_mobile/api"

/// API's list
enum API: String {
    // MARK: - Login
    
    case login = "/auth/2.9/login" //"/login"
    
    case tokenRenewal = "/token"
    
    case regDevice = "/regdevice"
    
    case errorCodes = "/errorCodes"
    
    // MARK: Device Registration token for push notifications
    
    case deviceRegistration = "/%@/deviceToken"
    
    // MARK: SignOut
       
    case signOut = "/%@/logout"
      
    case resetPassword = "/resetPass"
    
    case authorizeUser = "/authorize"   //"/oauth2/token" //
    
    case forgotPassword = "/fPass"
    
    case versionAPI = "/VERSION"

    
    var withBaseURL: String {
        return kBaseURLSWFT5 + kAPICommonPrefix + self.rawValue
    }

}

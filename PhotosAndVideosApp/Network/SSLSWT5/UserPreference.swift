//
//  WSDefaults.swift
//  WandApp
//
//  Created by Guruprasad on 11/10/17.
//  Copyright © 2017 PRO Unlimited, Inc. All rights reserved.
//

import Foundation

enum UserPreferenceKey: String {
    //Bool types
    case walkThroughShown
    case neverShowPushPermission
    case isErrorCodesNotDownloaded
    case hideSoftUpdateCard
    case hideExcludedClientsCard
    case isInterviewHomeCoachMarkShown
    case isInterviewDetailCoachMarkShown
    case alwaysAllowNonSecureLoads
    case isPushPermisionDeniedByUser
    case hideStaffingReqOnlyMsgCard
    case pushNotificationShownForFirstLaunch
    case biometricIdEnabled
    case biometricLoginHasError
    case biometricIdEnableAlertShown
    case isGoogleAnalyticsEnabled
    //int types
    case loginCount
    case prevLoginUserID
    
    //String types
    case deviceId
    case remoteNotificationDeviceToken
    case pKey
    case loginModel
    
}

/**
 User preference is wrapper around UserDefaults.
*/
class UserPreference {
    
    class func value<T>(forKey key: UserPreferenceKey) -> T? {

        switch key {
        case .walkThroughShown,
             .isErrorCodesNotDownloaded,
             .neverShowPushPermission,
             .biometricIdEnabled,
             .biometricIdEnableAlertShown,
             .biometricLoginHasError,
             .hideSoftUpdateCard,
             .hideStaffingReqOnlyMsgCard,
             .isInterviewDetailCoachMarkShown,
             .isInterviewHomeCoachMarkShown,
             .alwaysAllowNonSecureLoads,
             .isPushPermisionDeniedByUser,
             .pushNotificationShownForFirstLaunch,
             .hideExcludedClientsCard:
            return UserDefaults.standard.bool(forKey: key.rawValue) as? T
            
        case .loginCount,
             .prevLoginUserID:
            
           return UserDefaults.standard.integer(forKey: key.rawValue) as? T
            
        case .deviceId:
            return UserDefaults.standard.string(forKey: key.rawValue) as? T
            
        case .remoteNotificationDeviceToken:
            return UserDefaults.standard.string(forKey: key.rawValue) as? T
        case .pKey:
            return UserDefaults.standard.string(forKey: key.rawValue) as? T
        case .loginModel:
            return UserDefaults.standard.data(forKey: key.rawValue) as? T
        case .isGoogleAnalyticsEnabled:
            return UserDefaults.standard.object(forKey: key.rawValue) as? T
        }
    }
    
    class func set<T>(value: T?, forKey key: UserPreferenceKey) {
        
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
}

//
//  APIError.swift
//  WandApp
//
//  Created by Guruprasad Bhat on 04/12/17.
//  Copyright © 2017 PRO Unlimited, Inc. All rights reserved.
//

import Foundation

public enum APIError: Error {
    
    case noInternetConnection
    case invalidAccessToken
    case sessionExpired 
    case invalidRequest
    case invalidResponse
    case parsingError
    case somethingWentWrong
    case needRetry
    case requestCancelled
    case generalError(code: Int?, message: String?)
}

public enum SSLError: Int {
    case secureConnectionFailed = -1200
    case certificateHasBadDate = -1201
    case certificateUntrusted = -1202
    case certificateWithUnkownRoot = -1203
    case cerificateNotYetValid = -1204
    case certificateRejected = -1205
    case certificateRequired = -1206
    case unableToLoadFromNetwork = -2000
}

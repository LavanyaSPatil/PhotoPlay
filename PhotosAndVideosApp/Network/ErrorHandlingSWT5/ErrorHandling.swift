//
//  ErrorHandling.swift
//  WandApp
//
//  Created by Guruprasad on 10/24/17.
//  Copyright © 2017 PRO Unlimited, Inc. All rights reserved.
//
/*
import Foundation

public protocol ErrorHandler {
    
    func handleCommonAPIError(error: APIError) -> Bool
}

extension ViewModelOutput {
    
    func handleCommonAPIError(error: APIError) -> Bool {
        //here we will process different errors
        var handled = true
        switch error {
        case .noInternetConnection:
            let msg = DisplayStrings.noInternetErrorMsg.localised
            presentError(title: msg, message: "", handler: nil)
        case .invalidRequest:
            let msg = StatusCodesMessenger.shared.messageFor(statusCode: APIStatusCode.invalidRequest.rawValue)
            presentError(title: msg, message: "", handler: nil)
        default:
            handled = false
        }
        return handled
    }
}
*/

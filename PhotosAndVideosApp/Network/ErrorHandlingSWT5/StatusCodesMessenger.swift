////
////  ErrorCodesManager.swift
////  WandApp
////
////  Created by Prabhav on 21/11/17.
////  Copyright © 2017 PRO Unlimited, Inc. All rights reserved.
////
//
//import Foundation
//
//let ErrorCodesListName = "ErrorCodes"
//
//class StatusCodesMessenger {
//    private init() {}
//
//    static let shared = StatusCodesMessenger()
//
//    var errorCodesList: [ErrorCodes]?
//    var isErrorCodesNotDownloaded: Bool = true
//    var isErrorCodesArrayEmpty: Bool {
//        return ((self.errorCodesList?.count) != nil)
//    }
//
//    // MARK: - Custom Methods
//
//    var isErrorCodeResponsePresent: Bool {
//        let msg = self.messageFor(statusCode: 200, defaultMsg: "Not present")
//        return msg != "Not present"
//    }
//
//    func messageFor(statusCode: Int, defaultMsg: String = DisplayStrings.somethingWentWrong.localised) -> String {
//        var message: String?
//
//        if let _ = self.errorCodesList {
//            // If ErrorCodes are already saved in memory,
//            if self.errorCodesList?.count != 0 {
//                // set the message for the code from memory
//                for errorCodesItem in self.errorCodesList! {
//                    if errorCodesItem.eCode == statusCode {
//                        message = errorCodesItem.eMessage
//                        break
//                    }
//                }
//            } else {
//                // If errorCodesList is empty, Populate data from locally saved ErrorCodes.plist file to self.errorCodesList variable and show message for code
//                let errorsList = self.getErrorsFromPlist()
//                for errorCodesItem in errorsList {
//                    if errorCodesItem.eCode == statusCode {
//                        message = errorCodesItem.eMessage
//                        break
//                    }
//                }
//            }
//        } else { // If not in memory, Check if error codes are available in plist file, add it to errorCodesList and show message for code
//            let errorsList = self.getErrorsFromPlist()
//            for errorCodesItem in errorsList {
//                if errorCodesItem.eCode == statusCode {
//                    message = errorCodesItem.eMessage
//                    break
//                }
//            }
//        }
//        return message ?? defaultMsg
//    }
//
//    func saveErrorCode(errorCodes: [ErrorCodes]) {
//        if !errorCodes.isEmpty {
//            let fileManager = FileManager.default
//            let filepath = getErrorCodesFilePath()
//            debugPrint(filepath)
//            errorCodesList = errorCodes // Add ErrorCodes received to Memory
//            if !fileManager.fileExists(atPath: filepath) {
//                do {
//                    try fileManager.createDirectory(atPath: self.getErrorCodesFilePath(), withIntermediateDirectories: true, attributes: nil)
//                    fileManager.addSkipBackupAttributeToItemAtURL(filePath: filepath)
//                } catch {
//                    debugPrint(error.localizedDescription)
//                }
//            }
//
//            // convert ErrorCodesModel into dictionary &  write the dictionary into ErrorCodes.plist
//            var result = true
//            do {
//                let jsondata = try JSONEncoder().encode(errorCodes) // covert model to data
//                let jsonDict = try JSONSerialization.jsonObject(with: jsondata, options: JSONSerialization.ReadingOptions.allowFragments) // serialize data to jsonDict
//                let dict = NSDictionary(object: jsonDict, forKey: NSString(string: ErrorCodesListName)) // convert json dict to NSDictionary
//
//                result = dict.write(toFile: filepath.appending("/\(ErrorCodesListName).plist"), atomically: true)
//
//            } catch {
//                debugPrint("Encoding Error: \(error)")
//            }
//
//            UserPreference.set(value: !result, forKey: UserPreferenceKey.isErrorCodesNotDownloaded)
//            let flag: Bool? = UserPreference.value(forKey: UserPreferenceKey.isErrorCodesNotDownloaded)
//            self.isErrorCodesNotDownloaded = !(flag != nil)
//        }
//    }
//
//    fileprivate func getErrorsFromPlist() -> [ErrorCodes] {
//        let fileLocation = self.getErrorCodesFilePath()
//
//        if let fileDict = NSDictionary(contentsOfFile: fileLocation.appending("/\(ErrorCodesListName).plist")) {
//            do {
//                if let errorCodesDict = fileDict.value(forKey: ErrorCodesListName) {
//                    let jsonDict = try JSONSerialization.data(withJSONObject: errorCodesDict, options: .prettyPrinted)
//                    let errorsList = try JSONDecoder().decode([ErrorCodes].self, from: jsonDict)
//                    self.errorCodesList = errorsList
//                    return self.errorCodesList!
//                }
//            } catch {
//                debugPrint(error)
//            }
//        }
//        return []
//    }
//
//    private func getErrorCodesFilePath() -> String {
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
//        let documentsDirectory = paths.object(at: 0) as! NSString
//        let filepath = documentsDirectory.appendingPathComponent(ErrorCodesListName)
//
//        return filepath
//    }
//}
//



import Foundation

enum HandleError: Error {
    case invalidData
    case requestFailed
    case jsonConversionFailure
    case jsonParsingFailure
    case responseUnsuccessful
    case invalidRequest
    case resourceTimedOut // = -1001 /// Defined by iOS
    case notConnectedToInternet // = -1009 /// Defined by iOS
    case badRequest // = 400
    case unauthorized // = 401
    case forbidden // = 403
    case resourceNotFound // = 404
    case serverError // = 500
    case badGateway // = 501
    case serverUnavailable // = 503
    case noResponse // = -1000
    case unknown // = 1000

    var localizedDescription: String {
        switch self {
        case .invalidData:
            return "Invalid Data"
        case .requestFailed:
            return "Request Failed"
        case .jsonConversionFailure:
            return "JSON Conversion Failure"
        case .jsonParsingFailure:
            return "JSON Parsing Failure"
        case .responseUnsuccessful:
            return "Response Unsuccessful"
        case .invalidRequest:
            return "Invalid Request"
        case .resourceTimedOut:
            return "Resource timed out"
        case .notConnectedToInternet:
            return "Not connected to internet"
        case .badRequest:
            return "Server Error (Code 400)"
        case .unauthorized:
            return "Not authorized (Code 401)"
        case .forbidden:
            return "Resource forbidden (Code 403)"
        case .resourceNotFound:
            return "Resource not found (Code 404)"
        case .badGateway:
            return "Bad gateway (Code 501)"
        case .serverUnavailable:
            return "Service unavailable (Code 503)"
        case .serverError:
            return "Server Error (Code 500)"
        default:
            return "Some error occurred. Please try again"
        }
    }
}

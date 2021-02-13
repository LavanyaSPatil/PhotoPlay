

import Foundation
enum NetworkError: Int, Error, LocalizedError {

    typealias RawValue = Int

    /// Network/API Errors
    case resourceTimedOut = -1_001 /// Defined by iOS
    case notConnectedToInternet = -1_009 /// Defined by iOS
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case resourceNotFound = 404
    case serverError = 500
    case badGateway = 501
    case serverUnavailable = 503
    case noResponse = -1_000
    case unknown = 1_000

    var errorDescription: String? {
        switch self {
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

enum AppError: Error, LocalizedError {
    case responseNotParsable
    case networkError(code: Int)
    case wrap(error: Error)
    case noContentsFound

    var errorDescription: String? {
        switch self {
        case let .networkError(code):
            return NetworkError(rawValue: code)?.localizedDescription ?? "Some Error occured"
        case let .wrap(error): return error.localizedDescription
        case .noContentsFound: return "No contens found"
        default:
            return ""
        }
    }
}



import Foundation

protocol Request {
    var retryLimit: Int { get set }
    var retryTimeInterval: TimeInterval { get set }

    func request<T: Decodable> (with requests: URLRequest?,
                                completion: @escaping (Result<T, HandleError>) -> Void)
}

extension Request {

    func getSessionConfiguration() -> URLSessionConfiguration {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 60.0
        return sessionConfig
    }

    private func decodingData<T: Decodable> (with requests: URLRequest, decodingType: T.Type?, completion: @escaping (T?, HandleError?) -> Void) {
        retryNetworkRequest(countLimit: retryLimit, secondsAfter: retryTimeInterval, requests: requests, decodingType: decodingType, completion: completion)
    }

    private func retryNetworkRequest<T: Decodable> (countLimit: Int, secondsAfter: TimeInterval, requests: URLRequest, decodingType: T.Type?, completion: @escaping (T?, HandleError?) -> Void) {
        NetworkLogger.log(request: requests)
        let session = URLSession(configuration: getSessionConfiguration())
        let task = session.dataTask(with: requests) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                self.checkAndRetryTheNetworkCall(countLimit: countLimit, secondsAfter: secondsAfter, requests: requests, decodingType: decodingType, error: .requestFailed, completion: completion)
                return
            }
            switch httpResponse.statusCode {
            case 200...203 :
                if let data = data, let decode = decodingType {
                    do {
                        let genericModel = try JSONDecoder().decode(decode, from: data)
                        completion(genericModel, nil)
                    } catch {
                        completion(nil, .jsonConversionFailure)
                    }
                } else {
                    completion(nil, .invalidData)
                    return
                }
            case 400:
                self.checkAndRetryTheNetworkCall(countLimit: countLimit, secondsAfter: secondsAfter, requests: requests, decodingType: decodingType, error: .badRequest, completion: completion)
            case 401:
                completion(nil, .unauthorized)
            case 403:
                self.checkAndRetryTheNetworkCall(countLimit: countLimit, secondsAfter: secondsAfter, requests: requests, decodingType: decodingType, error: .forbidden, completion: completion)
            case 404:
                self.checkAndRetryTheNetworkCall(countLimit: countLimit, secondsAfter: secondsAfter, requests: requests, decodingType: decodingType, error: .resourceNotFound, completion: completion)
            case 500:
                self.checkAndRetryTheNetworkCall(countLimit: countLimit, secondsAfter: secondsAfter, requests: requests, decodingType: decodingType, error: .serverError, completion: completion)
            case 501:
                self.checkAndRetryTheNetworkCall(countLimit: countLimit, secondsAfter: secondsAfter, requests: requests, decodingType: decodingType, error: .badRequest, completion: completion)
            case 503:
                self.checkAndRetryTheNetworkCall(countLimit: countLimit, secondsAfter: secondsAfter, requests: requests, decodingType: decodingType, error: .serverUnavailable, completion: completion)
            default :
                self.checkAndRetryTheNetworkCall(countLimit: countLimit, secondsAfter: secondsAfter, requests: requests, decodingType: decodingType, error: .unknown, completion: completion)
            }
        }
        task.resume()
    }

    private func checkAndRetryTheNetworkCall <T: Decodable> (countLimit: Int, secondsAfter: TimeInterval, requests: URLRequest, decodingType: T.Type?, error: HandleError?, completion: @escaping (T?, HandleError?) -> Void) {
        if countLimit <= 0 {
            completion(nil, error)
        } else {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + secondsAfter) {
                self.retryNetworkRequest(countLimit: countLimit - 1, secondsAfter: secondsAfter, requests: requests, decodingType: decodingType, completion: completion)
            }
        }
    }

    func request<T: Decodable> (with requests: URLRequest?,
                                completion: @escaping (Result<T, HandleError>) -> Void) {
        guard let request = requests else {
            completion(Result.failure(.invalidRequest))
            return
        }
        decodingData(with: request, decodingType: T.self) { decodable, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(Result.failure(error))
                    return
                }
                guard let model = decodable else {
                    completion(Result.failure(.invalidData))
                    return
                }
                completion(Result.success(model))
            }
        }
    }
}

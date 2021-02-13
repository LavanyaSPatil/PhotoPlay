
import Foundation

enum Method: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}

protocol EndPoint {
  var path: String { get }
  var params: Any? { get }
  var method: Method { get }
  var queryDictionary: [String: Any]? { get }
  var host: String { get }
}

extension EndPoint {

  var headers: [String: String] {
    return ["Authorization" : "563492ad6f91700001000001c5adc7a160be4107b31fd967b4d6f135"]
  }

  var dataParms: Data? {
    guard let params = params else { return nil }
    let jsonData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    return jsonData
  }

  var urlComponents: URLComponents {
    //        let base: String = "http://dummy.restapiexample.com/api/"
    var component = URLComponents()
    component.scheme = "https"
    component.host = host
    component.path = path
    component.queryItems = queryDictionary?.queryItem
    return component
  }

  var request: URLRequest? {
    guard let url = urlComponents.url else {
      return nil
    }
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.httpBody = dataParms
    request.allHTTPHeaderFields = headers
    request.httpShouldHandleCookies = true
    return request
  }
}

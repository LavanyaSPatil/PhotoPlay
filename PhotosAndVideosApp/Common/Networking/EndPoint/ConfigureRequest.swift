

import Foundation

struct ConfigureRequest: EndPoint {
  var path: String
  var params: Any?
  var method: Method
  var queryDictionary: [String: Any]?
  var host: String
}

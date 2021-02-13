

import Foundation

extension Dictionary {

    var queryItem: [URLQueryItem]? {
        var output: [URLQueryItem] = []
        for (key, value) in self {
            output.append(URLQueryItem(name: "\(key)", value: "\(value)"))
        }
        return output
    }
}

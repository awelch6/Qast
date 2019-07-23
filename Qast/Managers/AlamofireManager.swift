//
//  AlamofireManager.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/22/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireManager {
    
    /// Helper method for single body response types
    static func basicRequest<T: Codable>(url: URL, method: HTTPMethod, headers: HTTPHeaders? = nil, responseObjectType: T.Type, _ completion: @escaping (Result<T>) -> Void) {
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if let error = response.error {
                return completion(.error(NSError(domain: error.localizedDescription, code: 303, userInfo: nil)))
            } else if let data = response.data {
                guard let response = try? JSONDecoder().decode(responseObjectType.self, from: data) else {
                    return completion(.error(NSError(domain: "Error decoding response object", code: 303, userInfo: nil)))
                }
                return completion(.value(response))
            }
        }
        
    }
}

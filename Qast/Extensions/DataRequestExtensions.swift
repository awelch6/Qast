//
//  DataRequestExtensions.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/22/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Alamofire response handlers

extension DataRequest {
        /// @Returns - DataRequest
        /// completionHandler handles JSON Object T
        @discardableResult func responseObject<T: Decodable> (
            queue: DispatchQueue? = nil ,
            completionHandler: @escaping (DataResponse<T>) -> Void ) -> Self {
            
            let responseSerializer = DataResponseSerializer<T> { _, response, data, error in
                guard error == nil else {return .failure(NSError(domain: "Network Error", code: 303, userInfo: nil))}
                
                let result = DataRequest.serializeResponseData(response: response, data: data, error: error)
                guard case let .success(jsonData) = result else {
                    return .failure(NSError(domain: "Error", code: 303, userInfo: nil))
                }
                
                // (1)- Json Decoder. Decodes the data object into expected type T
                // throws error when failes
                let decoder = JSONDecoder.newJSONDecoder()
                guard let responseObject = try? decoder.decode(T.self, from: jsonData) else {
                    return .failure(NSError(domain: "JSON object could not be serialized \(String(data: jsonData, encoding: .utf8)!)", code: 303, userInfo: nil))
                }
                return .success(responseObject)
            }
            return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
        }
        
        /// @Returns - DataRequest
        /// completionHandler handles JSON Array [T]
        @discardableResult func responseCollection<T: Decodable>(
            queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void
            ) -> Self {
            
            let responseSerializer = DataResponseSerializer<[T]> { _, response, data, error in
                guard error == nil else {return .failure(NSError(domain: "Error", code: 303, userInfo: nil))}
                
                let result = DataRequest.serializeResponseData(response: response, data: data, error: error)
                guard case let .success(jsonData) = result else {
                    return .failure(NSError(domain: "Error", code: 303, userInfo: nil))
                }
                
                let decoder = JSONDecoder.newJSONDecoder()
                guard let responseArray = try? decoder.decode([T].self, from: jsonData) else {
                    return .failure(NSError(domain: "JSON array could not be serialized \(String(data: jsonData, encoding: .utf8)!)", code: 303, userInfo: nil))
                }
                
                return .success(responseArray)
            }
            return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
        }
    }

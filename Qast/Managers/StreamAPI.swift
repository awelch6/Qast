//
//  StreamAPI.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/22/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation
import Alamofire

// It's possible we'll be with multiple stream providers. Easy enough to prepare with an interface to code to
protocol StreamMetadataAPI {
    func streamMetadata(getCoverArtUrlforIsrc isrc: String, _ completion: @escaping (Result<URL>) -> Void)
}

class UMGStreamMetadataAPI: StreamMetadataAPI {
    
    func streamMetadata(getCoverArtUrlforIsrc isrc: String, _ completion: @escaping (Result<URL>) -> Void) {
        let urlString = "https://hackathon.umusic.com/prod/v1/isrc/\(isrc)/cover"
        guard let url = URL(string: urlString) else {
            return completion(.error(NSError(domain: "Error", code: 303, userInfo: nil)))
        }
        let headers = ["x-api-key": "5dsb3jqxzX8D5dIlJzWoTaTM2TzcKufq1geS1SSb"]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject { (response: DataResponse<CoverArtResponse>) in
            
            switch response.result {
            case .success(let coverArtUrlResponse):
                guard let coverUrl = URL(string: coverArtUrlResponse.coverUrl) else {
                    return completion(.error(NSError(domain: "Unable to cast CoverArtUrlString to URL", code: 303, userInfo: nil)))
                }
                return completion(.value(coverUrl))
            case .failure(let error):
                return completion(.error(error))
            }
            
        }
        
    }
    
}

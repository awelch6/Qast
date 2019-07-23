//
//  CoverArtResponse.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/22/19.
//  Copyright © 2019 Qast. All rights reserved.
//

struct CoverArtResponse: Codable {
    let coverUrl: String
    
    enum CodingKeys: String, CodingKey {
        case coverUrl
    }
}

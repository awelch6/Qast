//
//  TrackMetadataResponse.swift
//  Qast
//
//  Created by Andrew O'Brien on 8/11/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation

struct TrackMetadataResponse: Codable {
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case title
    }
}

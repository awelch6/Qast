//
//  StreamMetadataAPI.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/23/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation

// May be dealing with multiple stream providers. Easy enough to prepare with an interface to code towards
protocol StreamMetadataAPI {
    func streamMetadata(getCoverArtUrlforIsrc isrc: String, _ completion: @escaping (Result<URL>) -> Void)
}

//
//  StreamMetadataAPI.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/23/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation

// It's possible we'll be with multiple stream providers. Easy enough to prepare with an interface to code to
protocol StreamMetadataAPI {
    func streamMetadata(getCoverArtUrlforIsrc isrc: String, _ completion: @escaping (Result<URL>) -> Void)
}

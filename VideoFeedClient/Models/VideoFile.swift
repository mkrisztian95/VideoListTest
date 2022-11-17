//
//  VideoFile.swift
//  VideoFeedClient
//
//  Created by Christian Molnar on 2022. 11. 17..
//

import Foundation
import ObjectMapper

struct VideoFile: CRUDObject {
    var id: Int?
    var quality: VideoQuality?
    var width: Int?
    var height: Int?
    var fps: Int?
    var url: String?

    init?(map: Map) {
        mapping(map: map)
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        quality <- map["quality"]
        width <- map["width"]
        height <- map["height"]
        fps <- map["fps"]
        url <- map["link"]
    }
}

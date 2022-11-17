//
//  SearchItemModel.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import Foundation
import Alamofire
import BrightFutures
import ObjectMapper

struct VideoModel: CRUDObject {
    var id: Int?
    var width: Int?
    var height: Int?
    var url: String?
    var image: String?
    var duration: Int?
    var user: User?
    var videoFiles: [VideoFile]?

    init?(map: Map) {
        mapping(map: map)
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        width <- map["width"]
        height <- map["height"]
        url <- map["url"]
        image <- map["image"]
        duration <- map["duration"]
        user <- map["user"]
        videoFiles <- map["video_files"]
    }
}

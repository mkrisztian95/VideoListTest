//
//  SearchResultWrapper.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import Foundation
import Alamofire
import BrightFutures
import ObjectMapper

struct ListResultWrapper: CRUDObject {
    var page: Int?
    var itemsPerPage: Int?
    var videos: [VideoModel]?

    init?(map: Map) {
        mapping(map: map)
    }

    mutating func mapping(map: Map) {
        page <- map["page"]
        itemsPerPage <- map["per_page"]
        videos <- map["videos"]
    }
}

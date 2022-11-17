//
//  User.swift
//  VideoFeedClient
//
//  Created by Christian Molnar on 2022. 11. 17..
//

import Foundation
import ObjectMapper

struct User: CRUDObject {
    var id: Int?
    var name: String?
    var url: String?

    init?(map: Map) {
        mapping(map: map)
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        url <- map["url"]
    }
}

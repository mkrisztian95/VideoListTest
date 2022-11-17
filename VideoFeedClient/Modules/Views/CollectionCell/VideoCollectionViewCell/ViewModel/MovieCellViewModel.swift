//
//  MovieCellViewModel.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import UIKit

typealias Action = () -> Void

class MovieCellViewModel {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let image: String
    let duration: Int
    var user: User?
    var lowQualityVideo: VideoFile?
    var highQualityVideo: VideoFile?

    init(model: VideoModel) {
        self.id = model.id ?? 0
        self.width = model.width ?? 0
        self.height = model.height ?? 0
        self.url = model.url ?? ""
        self.image = model.image ?? ""
        self.duration = model.duration ?? 0
        self.user = model.user
        self.lowQualityVideo = model.videoFiles?.filter({ video in
            return video.quality == .sd
        }).sorted(by: { v1, v2 in
            return v1.height ?? 0 < v2.height ?? 0
        }).first

        self.highQualityVideo = model.videoFiles?.filter({ video in
            return video.quality == .hd
        }).sorted(by: { v1, v2 in
            return v1.height ?? 0 > v2.height ?? 0
        }).first
    }
}

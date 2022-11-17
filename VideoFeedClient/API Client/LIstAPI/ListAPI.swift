//
//  SearchApi.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import Foundation
import Alamofire
import BrightFutures
import ObjectMapper

class ListAPI: APIClientManager, BaseApiProtocol {
    var method: HTTPMethod = .get

    var path: String = APIEndpoints.popularVideosEndpoint

    var parameters: [String: AnyObject]? = [:]

    func fetchVideos(page: Int = 1, numberOfItems perPage: Int = 10) -> Future<ListResultWrapper, Error> {
        parameters?[ParameterKeys.List.page] = page as AnyObject
        parameters?[ParameterKeys.List.perPage] = perPage as AnyObject
        return getObject(path, params: parameters, method: method, encoding: PartnersEncoding(), token: EnvironmentVars.apiToken)
    }
}

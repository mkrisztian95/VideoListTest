//
//  APIClientManager.swift
//  
//
//  Created by Chris on 16.11.2022.
//  Copyright © 2022 Chris. All rights reserved.
//

import UIKit
import Alamofire
import BrightFutures
import ObjectMapper

typealias ErrorHandler = (NSError) -> Void

// swiftlint:disable line_length
class APIClientManager {

    // MARK: - Variables -
    var baseURL: URL = {
        guard let url = URL(string: EnvironmentVars.apiHost) else {
            fatalError("Please Set up a base URL")
        }
        return url
    }()

    internal var dataProvider: NetworkDataProvider = NetworkDataProvider()
    var defaultErrorHandler: ErrorHandler?

    init () {
        configraiteDataProvider()
    }

    func configraiteDataProvider() {
        let urlSessionConfig = URLSessionConfiguration.default

        let baseURL = EnvironmentVars.apiHost

        if let baseAPI = URL(string: baseURL), let  host = baseAPI.host {
            let serverTrustManager = ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [host: DisabledTrustEvaluator()])
            let dataProvider = NetworkDataProvider(configuration: urlSessionConfig, serverTrustManager: serverTrustManager)
            self.dataProvider = dataProvider
        }
    }

    // MARK: - Error handling
    func handleFailure<R>(_ failed: @escaping () -> Future<R, Error>) -> Future<R, Error> {
        return failed().onFailure { _ in

        }
    }

    // MARK: - Generic requests -
    internal func getData(_ endpoint: String, params: [String: AnyObject]? = nil, method: Alamofire.HTTPMethod? = nil, encoding: ParameterEncoding? = nil) -> Future<Any, Error> {

        typealias CRUDResultType = (Alamofire.DataRequest, Future<Any, Error>)
        let request = self.readRequest(baseURL, token: EnvironmentVars.apiToken, endpoint: endpoint, method: method, params: params, encoding: encoding)
        let (_, future): CRUDResultType = self.dataProvider.dataRequest(request)
        return future
    }

    internal func getObject<C: CRUDObject>(_ endpoint: String, params: [String: AnyObject]? = nil, method: Alamofire.HTTPMethod? = nil, encoding: ParameterEncoding? = nil, token: String? = nil) -> Future<C, Error> {
        typealias CRUDResultType = (Alamofire.DataRequest, Future<C, Error>)

        let request = self.readRequest(baseURL, token: token, endpoint: endpoint, method: method, params: params, encoding: encoding)
        let (_, future): CRUDResultType = self.dataProvider.objectRequest(request)
        return future
    }

    internal func getObjects<C: CRUDObject>(_ url: URL, endpoint: String, params: [String: AnyObject]? = nil, method: Alamofire.HTTPMethod? = nil, encoding: ParameterEncoding? = nil, token: String? = nil) -> Future<[C], Error> {
        typealias CRUDResultType = (Alamofire.DataRequest, Future<[C], Error>)

        let request = self.readRequest(url, token: token, endpoint: endpoint, method: method, params: params, encoding: encoding)
        let (_, future): CRUDResultType = self.dataProvider.arrayRequest(request)
        return future
    }

    internal func getObjectsCollection<C: CRUDObject>(_ url: URL, endpoint: String, params: [String: AnyObject]? = nil, method: Alamofire.HTTPMethod? = nil, encoding: ParameterEncoding? = nil) -> Future<CollectionResponse<C>, Error> {
        typealias CRUDResultType = (Alamofire.DataRequest, Future<CollectionResponse<C>, Error>)

        let request = self.readRequest(url, token: EnvironmentVars.apiToken, endpoint: endpoint, method: method, params: params, encoding: encoding)
        let (_, future): CRUDResultType = self.dataProvider.objectRequest(request)
        return future
    }

    internal func https(_ newUrl: URL, endpoint: String) -> URL {
        return url(newUrl, endpoint: endpoint, scheme: "https")
    }

    fileprivate func url(_ kUrl: URL? = nil, endpoint: String, scheme: String, port: Int? = nil) -> URL {
        let newUrl = kUrl ?? baseURL
        if var components = URLComponents(url: newUrl, resolvingAgainstBaseURL: false) {
            components.scheme = scheme
            components.path = (components.path as NSString).appendingPathComponent(endpoint)
            if let port = port {
                components.port = port
            }
            if let url = components.url {
                return url
            }
        }
        fatalError("Could not generate  url")
    }

    internal func readRequest(_ newUrl: URL, token: String?, endpoint: String, method: Alamofire.HTTPMethod? = nil, params: [String: AnyObject]? = nil, encoding: ParameterEncoding? = nil) -> CRUDRequest {
        let request = CRUDRequest(token: token, url: https(newUrl, endpoint: endpoint))
        request.params = params
        if let method = method {
            request.method = method
            request.encoding = JSONEncoding.default
        }
        if let encoding = encoding {
            request.encoding = encoding
        }
        return request
    }

    internal func updateRequest(_ newUrl: URL, token: String?, endpoint: String, method: Alamofire.HTTPMethod = .post, params: [String: AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = JSONEncoding.default) -> CRUDRequest {
        let request = CRUDRequest(token: token, url: https(newUrl, endpoint: endpoint))
        request.encoding = encoding
        request.method = method
        request.params = params
        return request
    }
}

// MARK: - CRUD request -
extension APIClientManager {

    internal final class CRUDRequest: Alamofire.URLRequestConvertible {

        let token: String?
        let url: URL

        var additionalHeaders: [String: String]?
        var method: HTTPMethod = .get
        var params: [String: AnyObject]?
        var encoding: Alamofire.ParameterEncoding = URLEncoding.default
        var httpBody: Data?

        init(token: String?, url: URL) {
            self.token = token
            self.url = url
        }
        /// Returns a URL request or throws if an `Error` was encountered.
        ///
        /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
        ///
        /// - returns: A URL request.
        func asURLRequest() throws -> URLRequest {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue

            var headers = [
                "Accept": "application/json",
                "Connection": "close"
                ]
            if let token = token {
                if token.count > 0 {
                    headers = [
                        "\(ParameterKeys.Token.tokenKey)": "\(token)",
                        "Connection": "close",
                        "Set-Cookie": "store=ua",
                        "store": "ua"
                    ]
                }
            }

            if let additionalHeaders = additionalHeaders {
                for (key, value) in additionalHeaders {
                    headers.updateValue(value, forKey: key)
                }
            }
            urlRequest.allHTTPHeaderFields = headers
            urlRequest.httpBody = httpBody
            urlRequest.setValue(" application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            do {
                let urlReq = try encoding.encode(urlRequest as URLRequestConvertible, with: params)

                return urlReq
            } catch {

                return URLRequest(url: URL(fileURLWithPath: ""))
            }
        }
    }
}

protocol CRUDObject: Mappable, CustomStringConvertible {

    static func endpoint() -> String
}

extension CRUDObject {
    static func endpoint() -> String {
        return ""
    }

    var description: String {
        return "<\(Swift.type(of: self))>"
    }
}

struct CollectionResponse<C: CRUDObject>: Mappable {
    fileprivate(set) var items: [C]!

    init(items: [C]) {
        self.items = items
    }

    init?(map: Map) {
        mapping(map: map)
        switch items {
        case (.some):
            break
        default:
            return nil
        }
    }

    mutating func mapping(map: Map) {
        items <- map["objectList"]
    }

    var description: String {
        return "<\(Swift.type(of: self))-(\(String(describing: items))>"
    }
}
// swiftlint:enable line_length

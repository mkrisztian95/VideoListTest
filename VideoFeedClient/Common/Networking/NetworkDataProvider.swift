//
//  NetworkDataProvider.swift
//  
//
//  Created by Chris on 16.11.2022.
//  Copyright © 2022 Chris. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import BrightFutures
import MobileCoreServices
import NotificationBannerSwift

open class NetworkDataProvider {

    open  func uploadRequest<V>(
        _ URLRequest: Alamofire.URLRequestConvertible,
        map: @escaping (AnyObject?) -> V?,
        files: [FileUpload],
        row: Int? = nil,
        name: String? = nil) -> (Future<V, NSError>) {
            return uploadRequest(URLRequest, files: files, row: row, name: name)
        }

    /**
     Create request for mappable object
     
     - parameter URLRequest: The URL request
     
     - returns: Tuple with request and future
     */
    open func dataRequest(_ URLRequest: Alamofire.URLRequestConvertible,
                          validation: Alamofire.DataRequest.Validation? = nil) -> (Alamofire.DataRequest, Future<Any, Error>) {
        return request(URLRequest, validation: validation)
    }

    open func objectRequest<T: Mappable>(
        _ URLRequest: Alamofire.URLRequestConvertible,
        validation: Alamofire.DataRequest.Validation? = nil
    ) -> (Alamofire.DataRequest, Future<T, Error>) {
        let mapping: (AnyObject?) -> T? = { json in
            return Mapper<T>().map(JSONObject: json)
        }
        return jsonRequest(URLRequest, map: mapping, validation: validation)
    }

    /**
     Create request for multiple mappable objects
     
     - parameter URLRequest: The URL request
     
     - returns: Tuple with request and future
     */
    open func arrayRequest<T: Mappable>(
        _ URLRequest: Alamofire.URLRequestConvertible,
        validation: Alamofire.DataRequest.Validation? = nil
    ) -> (Alamofire.DataRequest, Future<[T], Error>) {
        let mapping: (AnyObject?) -> [T]? = { json in
            return Mapper<T>().mapArray(JSONObject: json)
        }
        return jsonRequest(URLRequest, map: mapping, validation: validation)
    }

    /**
     Create request with JSON mapping
     
     - parameter URLRequest: The URL request
     - parameter map:        Response mapping function
     
     - returns: Tuple with request and future
     */
    open  func jsonRequest<V>(
        _ URLRequest: Alamofire.URLRequestConvertible,
        map: @escaping (AnyObject?) -> V?,
        validation: Alamofire.DataRequest.Validation? = nil
    ) -> (Alamofire.DataRequest, Future<V, Error>) {
        return request(URLRequest, map: map, validation: validation)
    }

    /**
     Designated initializer
     
     - parameter api:           api service
     - parameter configuration: session configuration
     
     - returns: new instance
     */

    public init(
        configuration: URLSessionConfiguration = URLSessionConfiguration.default,
        serverTrustManager: ServerTrustManager? = nil) {
            let monitor = ClosureEventMonitor()
            monitor.requestDidCreateTask = { (request, _) in
                print("Request:\n\(request.cURLDescription())")
            }

            // disable default credential store
            configuration.urlCredentialStorage = nil
            let backgroundQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).backgroundtransfer")

            sessionManager = Alamofire.Session(configuration: configuration, serverTrustManager: serverTrustManager, eventMonitors: [monitor])
            self.backgroundSessionManager = Alamofire.Session(configuration: configuration, rootQueue: backgroundQueue, serverTrustManager: serverTrustManager, eventMonitors: [monitor])
            listenForReachability()
        }

    /// Singleton instance
    static let sharedInstance = NetworkDataProvider()
    fileprivate let sessionManager: Alamofire.Session
    public var backgroundSessionManager: Alamofire.Session // your web services you intend to keep running when the system backgrounds your app will use this
    fileprivate let activityIndicator = NetworkActivityIndicatorManager()
    fileprivate let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    fileprivate var notReachable: Bool = false

    /**
     Create request with serializer
     
     - parameter URLRequest: The URL request
     - parameter serializer: Response serializer
     
     - returns: Tuple with request and future
     */
    open func request<V: Any> (
        _ URLRequest: Alamofire.URLRequestConvertible,
        map: @escaping (AnyObject?) -> V?,
        validation: Alamofire.DataRequest.Validation?) -> (Alamofire.DataRequest, Future<V, Error>) {

            let promise = Promise<V, Error>()

            activityIndicator.increment()

            let request: DataRequest =  self.request(URLRequest, validation: validation)
            request.responseJSON(queue: DispatchQueue.main, options: .allowFragments) { response in
                self.activityIndicator.decrement()
                switch response.result {
                case .success(let value):
                    if let response = response.response {
                        Logger.logString(value: "\n################ Status: \(response.statusCode.description),\n,\n################ JSON: \(value)")
                    } else {
                        Logger.logString(value: "\n################ JSON: \(value)")
                    }
                    guard let object = map(value as AnyObject?) else {
                        if let error = response.result.error {
                            promise.failure(error)
                        }
                        return
                    }
                    if response.response?.statusCode == 412 {
                        if let json = value as? NSDictionary {
                            let error = NSError(domain: (response.response?.url?.host)!, code: response.response!.statusCode, userInfo: json as? [String: Any])
                            promise.failure(error)
                        }
                    } else {
                        promise.success(object)
                    }
                case .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)):
                    if let response = response.response {
                        Logger.logString(value: "\n################ Status: \(response.statusCode.description),\n################ JSON: inputDataNilOrZeroLength")
                    } else {
                        Logger.logString(value: "\n################ JSON: inputDataNilOrZeroLength")
                    }
                    // swiftlint:disable all
                    promise.success(response.result.value as? V ?? "" as! V)
                    // swiftlint:enable all
                case .failure(let error):
                    promise.failure(error)
                }
            }

            return (request, promise.future)
        }

    /**
     Create request with serializer
     
     - parameter URLRequest: The URL request
     - parameter serializer: Response serializer
     
     - returns: Tuple with request and future
     */
    open func request (_ URLRequest: Alamofire.URLRequestConvertible,
                       validation: Alamofire.DataRequest.Validation?) -> (Alamofire.DataRequest, Future<Any, Error>) {

        activityIndicator.increment()

        let promise = Promise<Any, Error>()

        let request: DataRequest =  self.request(URLRequest, validation: validation)
        request.responseJSON(queue: DispatchQueue.main, options: .allowFragments) { response in
            self.activityIndicator.decrement()
            switch response.result {
            case .success(let value):
                if let response = response.response {
                    Logger.logString(value: "\n################ Status: \(response.statusCode.description),\n,\n################ JSON: \(value)")
                } else {
                    Logger.logString(value: "\n################ JSON: \(value)")
                }
                if response.response?.statusCode == 412 {
                    if let json = value as? NSDictionary {
                        let error = NSError(domain: (response.response?.url?.host)!, code: response.response!.statusCode, userInfo: json as? [String: Any])
                        promise.failure(error)
                    }
                } else {
                    promise.success(value)
                }
            case .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)):
                if let response = response.response {
                    Logger.logString(value: "\n################ Status: \(response.statusCode.description),\n################ JSON: inputDataNilOrZeroLength")
                } else {
                    Logger.logString(value: "\n################ JSON: inputDataNilOrZeroLength")
                }
                promise.success(response.result.value ?? "")
            case .failure(let error):
                promise.failure(error)
            }

        }

        return (request, promise.future)
    }

    fileprivate func request(_ URLRequest: Alamofire.URLRequestConvertible, validation: Alamofire.DataRequest.Validation?) -> Alamofire.DataRequest {
        let request = sessionManager.request(URLRequest)
        if let validation = validation {
            return request.validate(validation)
        } else {
            var acceptableStatusCodes = Array(200..<300)
            acceptableStatusCodes.append(412)
            return request.validate(statusCode: acceptableStatusCodes)
        }
    }

    open func uploadRequest<V: Any> (
        _ URLRequest: Alamofire.URLRequestConvertible,
        files: [FileUpload],
        row: Int? = nil,
        name: String? = nil) -> (Future<V, NSError>) {

            let promise = Promise<V, NSError>()

            activityIndicator.increment()

            self.sessionManager.upload(multipartFormData: { (multipartFormData) in

                for fileInfo in files {
                    multipartFormData.append(fileInfo.data,
                                             withName: fileInfo.name,
                                             fileName: fileInfo.filename,
                                             mimeType: fileInfo.mimeType)
                }
            }, with: URLRequest).uploadProgress { (progress) in
                Logger.logString(value: "uploding")
                Logger.logString(value: "upload progress: \(progress.fractionCompleted)")
                var object: [String: Any] = ["progress": progress.fractionCompleted]
                if let row = row {
                    object["row"] = row
                }
                if let name = name {
                    object["name"] = name
                }
                NotificationCenter.default.post(
                    name: NSNotification.Name("Progress"),
                    object: (object)
                )
            }.responseString { response in
                Logger.logString(value: "done")

                self.activityIndicator.decrement()
                switch response.result {
                case .success(let value):
                    // swiftlint:disable all
                    promise.success(value as! V)
                    // swiftlint:enable all
                case .failure(let error):
                    promise.failure(error as NSError)
                }
            }

            return promise.future
        }

    func isInternetReachable() -> Bool {
        if let isReachable = self.reachabilityManager?.isReachable {
            return isReachable
        }
        return false
    }
}

// MARK: Upload
extension NetworkDataProvider {

    /// File upload info
    final public class FileUpload {
        let data: Data
        let name: String
        let filename: String
        let mimeType: String

        public init (data: Data, dataUTI: String, name: String = "image") {
            self.name = "image"
            self.data = data
            mimeType = copyTag(kUTTagClassMIMEType, fromUTI: dataUTI, defaultValue: dataUTI)
            var fileNameArr = name.components(separatedBy: ".")

            var fileName = ""
            var  fileExtension = ""
            if fileNameArr.count > 1 {
                fileExtension = fileNameArr.last ?? ""
                fileNameArr.removeLast()
                fileName =  fileNameArr.joined(separator: ".")
            } else {
                fileName = name
                fileExtension = copyTag(kUTTagClassFilenameExtension, fromUTI: dataUTI, defaultValue: dataUTI)
            }

            filename = (fileName as NSString).appendingPathExtension(fileExtension) ?? fileName
        }
    }

    /**
     Uploads a files
     
     - parameter URLRequest: url request
     - parameter urls:       files info
     
     - returns: Request future
     */
    public func upload(_ URLRequest: Alamofire.URLRequestConvertible, files: [FileUpload], row: Int? = nil, name: String? = nil) -> (Future<AnyObject?, NSError>) {
        let promise = Promise<AnyObject?, NSError>()

        backgroundSessionManager.upload(multipartFormData: { (multipartFormData) in
            for fileInfo in files {
                multipartFormData.append(fileInfo.data,
                                         withName: fileInfo.name,
                                         fileName: fileInfo.filename,
                                         mimeType: fileInfo.mimeType)
            }
        }, with: URLRequest).uploadProgress { (progress) in
            Logger.logString(value: "upload progress: \(progress.fractionCompleted)")

            var object: [String: Any] = ["progress": progress.fractionCompleted]
            if let row = row {
                object["row"] = row
            }
            if let name = name {
                object["name"] = name
            }
            NotificationCenter.default.post(
                name: NSNotification.Name("Progress"),
                object: (object)
            )
        }.validate(statusCode: [201]).responseJSON { response in
            switch response.result {
            case .success(let JSON):
                promise.success(JSON as AnyObject?)
            case .failure(let error):
                promise.failure(error as NSError)
            }
        }

        return promise.future
    }
}

// MARK: 
extension NetworkDataProvider {
    func showReachabilityMessage(title: String?, style:BannerStyle) {
        let banner = FloatingNotificationBanner(title: title, style: style)
        banner.dismissOnTap = true
        banner.dismissOnSwipeUp = true
        banner.autoDismiss = true
        banner.show()
    }

    func listenForReachability() {
        self.reachabilityManager?.startListening(onUpdatePerforming: {networkStatusListener in

            Logger.logString(value: "Network Status Changed: \(networkStatusListener)")

            switch networkStatusListener {
            case .notReachable:
                // Show error state
                self.notReachable = true
                self.showReachabilityMessage(title: R.string.localizable.lostConnection(), style: .danger)
            case .reachable(let connection):
                // Hide error state
                self.showReachabilityMessage(title: connection == .ethernetOrWiFi ? R.string.localizable.connectedWifi() : R.string.localizable.connectedCellular(), style: .success)
                if self.notReachable {
                    self.notReachable = false
                }
            case .unknown:
                if self.notReachable {
                    self.notReachable = false
                }
            }
        })
    }
}

private func copyTag(_ tag: CFString!, fromUTI dataUTI: String, defaultValue: String) -> String {
    guard let str = UTTypeCopyPreferredTagWithClass(dataUTI as CFString, tag) else {
        return defaultValue
    }
    return str.takeRetainedValue() as String
}

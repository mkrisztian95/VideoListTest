//
//  PartnersEncoding.swift
//  
//
//  Created by Chris on 16.11.2022.
//  Copyright © 2022 Chris. All rights reserved.
//

import UIKit
import Alamofire

public struct PartnersEncoding: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var mutableURLRequest = try urlRequest.asURLRequest()

        let parameterArray = parameters?.map { (key, value) -> String in
            let percentEscapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            if let value = value as? String {
                let percentEscapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                return "\(percentEscapedKey)=\(percentEscapedValue)"
            }

            if let value = value as? Int {
                return "\(percentEscapedKey)=\(value)"
            }

            if let valueArray = value as? [String] {
                var resultString = ""
                for valueItem in valueArray {
                    let percentEscapedValue = valueItem.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""

                    if resultString.count != 0 {
                        resultString += "&"
                    }

                    resultString += "\(percentEscapedKey)=\(percentEscapedValue)"
                }
                return resultString
            }

            return ""
            } ?? []

        if var urlComponents = URLComponents(url: mutableURLRequest.url!, resolvingAgainstBaseURL: false) {
            let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + parameterArray.joined(separator: "&")
            urlComponents.percentEncodedQuery = percentEncodedQuery
            mutableURLRequest.url = urlComponents.url
        }

        return mutableURLRequest
    }
}

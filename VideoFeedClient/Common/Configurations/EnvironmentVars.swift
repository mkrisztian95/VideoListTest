//
//  AppConfiguration.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import Foundation

private struct EnvironmentKeys {
    static let apiBaseURL = "ApiBaseURL"
    static let apiVersion = "APIVersion"
    static let scheme = "Scheme"
    static let apiToken = "APIToken"
}

struct EnvironmentVars {
    static let scheme: String = {
        let value = Bundle.main.infoDictionary?[EnvironmentKeys.scheme] as? String ?? "test"
            return value
    }()

    static let baseApiHost: String = {
        let value = Bundle.main.infoDictionary?[EnvironmentKeys.apiBaseURL] as? String ?? ""
        return value
    }()

    static let apiVersion: String = {
        let value = Bundle.main.infoDictionary?[EnvironmentKeys.apiVersion] as? String ?? ""
        return value
    }()

    static let apiHost: String = {
        return "https://\(baseApiHost)/\(apiVersion)/"
    }()

    static let apiToken: String = {
        let value = Bundle.main.infoDictionary?[EnvironmentKeys.apiToken] as? String ?? ""
        return value
    }()
}

//
//  String+DateFormatter.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import Foundation

extension String {

    func getDate() -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}

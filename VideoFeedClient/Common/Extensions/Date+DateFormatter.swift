//
//  Date+DateFormatter.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import Foundation

extension Date {
    func getFormattedString(string: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = string
        return formatter.string(from: self)
    }

    func getPrettyDate() -> String {
        return self.getFormattedString(string: "MMMM dd, yyyy")
    }
}

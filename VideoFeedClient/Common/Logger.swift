//
//  Logger.swift
//  charpic
//
//  Created by Chris on 26.04.2021.
//

import UIKit

class Logger: NSObject {
    static func logError(err: Error) {
        print("🆘🆘🆘🆘🆘🆘🆘🆘🆘🆘")
        print(err.localizedDescription)
        print("🆘🆘🆘🆘🆘🆘🆘🆘🆘🆘")
    }

    static func logString(value: String) {
        print("✋✋✋✋✋✋✋✋✋✋")
        print(value)
        print("✋✋✋✋✋✋✋✋✋✋")
    }

    static func logError(err: NSError) {
        print("🆘🆘🆘🆘🆘🆘🆘🆘🆘🆘")
        print("\(err.code) - " + err.localizedDescription)
        print("🆘🆘🆘🆘🆘🆘🆘🆘🆘🆘")
    }

    static func logSuccess(string: String) {
        print("🍾🍾🍾🍾🍾🍾🍾🍾🍾🍾")
        print(string)
        print("🍾🍾🍾🍾🍾🍾🍾🍾🍾🍾")
    }
}

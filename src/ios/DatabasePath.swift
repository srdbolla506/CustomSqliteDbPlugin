//
//  DatabasePath.swift
//  PackageDelivery
//
//  Created by Sri Divya Bolla on 13/06/21.
//

import Foundation


public func destroyDatabase(databasePath: String?) {
    guard let path = databasePath else {
        return
    }

    do {
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
    } catch {
        debugPrint("Could not destroy database at \(path)")
    }
}


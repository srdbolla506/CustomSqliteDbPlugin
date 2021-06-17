//
//  SqlitePlugin.swift
//  PackageDelivery
//
//  Created by Sri Divya Bolla on 13/06/21.
//

import UIKit


@objc(SqlitePlugin)
class SqlitePlugin: CDVPlugin {
    var db: SQLiteDatabase?

    @objc func openDB(_ command: CDVInvokedUrlCommand) {
        do {
            if let databasePath = command.arguments[0] as? String {
                db = try SQLiteDatabase.open(path: databasePath)
                returnResult(command, message: "Sqlite DB at path \(databasePath) has been successfully created or opened", success: true)
            }
        } catch SQLiteError.OpenDatabase(_) {
            returnResult(command, message: "Unable to open database.", success: false)
        } catch let error {
            returnResult(command, message: "\(error.localizedDescription)", success: false)
        }
    }
    
    @objc func closeDB(_ command: CDVInvokedUrlCommand) {
        db?.closeDB()
        returnResult(command, message: "Connection to DB closed", success: true)
    }
    
    @objc func executeSQLStatement(_ command: CDVInvokedUrlCommand) {
        if let sqlStatement = command.arguments[0] as? String {
            let successOrErrorMessage = db?.executeSQLStatement(sqlStatement: sqlStatement)
            returnResult(command, message: successOrErrorMessage?.0, success: successOrErrorMessage?.1 ?? false)
        } else {
            returnResult(command, message: "Input is not proper", success: false)
        }
    }
    
    @objc func insertIntoTable(_ command: CDVInvokedUrlCommand) {
        if let sqlStatement = command.arguments[0] as? String {
            let successOrErrorMessage = db?.insertRowsIntoTable(sqlStatement: sqlStatement)
            returnResult(command, message: successOrErrorMessage?.1 ?? "", success: successOrErrorMessage?.0 ?? false)
        } else {
            returnResult(command, message: "Input is not proper", success: false)
        }
    }
    
    @objc func destroyDatabase(_ command: CDVInvokedUrlCommand) {
        if let databasePath = command.arguments[0] as? String {
            let successOrErrorMessage = SQLiteDatabase.destroyDatabase(databasePath: databasePath)
            returnResult(command, message: successOrErrorMessage.0, success: successOrErrorMessage.1)
        } else {
            returnResult(command, message: "Input is not proper", success: false)
        }
    }

    func returnResult(_ command: CDVInvokedUrlCommand, message: Any?, success: Bool) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        if success == true {
            switch message.self {
            case is String:
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: message as? String ?? ""
                )
                break
            case is [ResultRow]:
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: message as? [ResultRow] ?? []
                )
                break
            default:
                break
            }
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
}

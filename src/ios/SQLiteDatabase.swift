//
//  SQLiteDatabase.swift
//  PackageDelivery
//
//  Created by Sri Divya Bolla on 13/06/21.
//

import Foundation
import SQLite3


enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

typealias ResultRow = [String: Any?]

class SQLiteDatabase {
    private let dbPointer: OpaquePointer?
    
    fileprivate var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    func closeDB() {
        sqlite3_close(dbPointer)
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
        
        var db: OpaquePointer?
        // 1
        if sqlite3_open(path, &db) == SQLITE_OK {
            // 2
            return SQLiteDatabase(dbPointer: db)
        } else {
            // 3
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError
                .OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
    
    fileprivate func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil)
                == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        return statement
    }
    
    func insertRowsIntoTable(sqlStatement: String) -> (Bool, String) {
        do {
            try insertIntoTable(sqlStatement: sqlStatement)
            return (true, "Successfully inserted row.")
        } catch let error {
            return (false, "\(error.localizedDescription)")
        }
    }
    
    fileprivate func insertIntoTable(sqlStatement: String) throws {
        let insertStatement = try prepareStatement(sql: sqlStatement)
        
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        let id: Int32 = 1
        let name: NSString = ""
        
        guard
            sqlite3_bind_int(insertStatement, 1, id) == SQLITE_OK  &&
                sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
                == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        print("Successfully inserted row.")
    }
    
    func executeSQLStatement(sqlStatement: String) -> (Any, Bool) {
        var queryStatement: OpaquePointer?
        do {
            queryStatement = try prepareStatement(sql: sqlStatement)
        } catch {
            let errorMessage = String(cString: sqlite3_errmsg(queryStatement))
            return (errorMessage, false)
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        var statementExecuted = sqlite3_step(queryStatement)
        
        
        switch(statementExecuted) {
        case SQLITE_ROW:
            var resultArray: [ResultRow] = []
            
            while(statementExecuted == SQLITE_ROW) {
                var resultRowDictionary: [String: Any?] = [:]
                let columnCount = sqlite3_column_count(queryStatement)
                for i in 0..<columnCount {
                    let columnName = String(cString: sqlite3_column_name(queryStatement, i))
                    let columnType = sqlite3_column_type(queryStatement, i)
                    var columnValue: Any?
                    switch columnType {
                    case SQLITE_INTEGER:
                        columnValue = sqlite3_column_int64(queryStatement, i)
                        break
                    case SQLITE_FLOAT:
                        columnValue = sqlite3_column_double(queryStatement, i)
                        break
                    case SQLITE_BLOB:
                        columnValue = sqlite3_column_blob(queryStatement, i)
                        break
                    case SQLITE_TEXT:
                        columnValue = sqlite3_column_text(queryStatement, i)
                        break
                    default:
                        columnValue = nil
                        break
                    }
                    resultRowDictionary[columnName] = columnValue
                }
                resultArray.append(resultRowDictionary)
                statementExecuted = sqlite3_step(queryStatement)
            }
            return (resultArray, true)
        case SQLITE_DONE:
            return ("Successfully updated or deleted row.", true)
        default:
            let errorMessage = String(cString: sqlite3_errmsg(queryStatement))
            return (errorMessage, false)
        }
    }
    
    
    static func destroyDatabase(databasePath: String?) -> (String, Bool) {
        guard let path = databasePath else {
            return ("Path doesn't exists", false)
        }

        do {
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
                return ("Db at path \(path) has been destroyed", true)
            } else {
                return ("Db doesn't exist at path \(path)", true)
            }
        } catch {
            return ("Could not destroy database at \(path)", false)
        }
    }

    
}

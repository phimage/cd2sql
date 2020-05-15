//
//  Command.swift
//
//  Created by phimage on 15/05/2020.
//

import Foundation
import ArgumentParser
import MomXML
import SWXMLHash
import FileKit

struct Command: ParsableCommand {

    static let configuration = CommandConfiguration(abstract: "Transform core data model to SQL")

    @Option(help: "The core data model path.")
    var path: String?

    @Argument(help: "The core data model path.")
    var pathArg: String?

    @Option(default: "", help: "Format sush as 'sqlite'")
    var format: String? // SQLite

    @Option(default: "keyMapping", help: "Search table and field names inside userinfo using this key")
    var mapping: String?

    @Option(help: "userinfo key used to find primary key (default: primaryKey)")
    var primaryKey: String?

    // @Flag  [IF NOT EXISTS]

    func validate() throws {
        guard let path = self.path ?? self.pathArg else {
            throw ValidationError("'<path>' of core data model not specified.")
        }
        guard Path(path).exists else {
            throw ValidationError("'<path>' \(path) doesn't not exist.")
        }
    }

    func run() throws {
         var modelURL = URL(fileURLWithPath: self.path ?? self.pathArg ?? "")
         if modelURL.pathExtension == "xcdatamodeld" {
             modelURL = modelURL.appendingPathComponent("\(modelURL.deletingPathExtension().lastPathComponent).xcdatamodel")
         }
         if modelURL.pathExtension == "xcdatamodel" {
             modelURL = modelURL.appendingPathComponent("contents")
         }

        let xmlString = try String(contentsOf: modelURL)
        let xml = SWXMLHash.parse(xmlString)
        guard let parsedMom = MomXML(xml: xml) else {
            error("Failed to parse \(modelURL)")
            return
         }
         let sqliteLite = format == "sqlite"

        for entity in parsedMom.model.entities {
            let tableName = entity.name(sqlite: sqliteLite, mapping: mapping)
            var sql = "CREATE TABLE \(tableName) (\n"
            let primaryKey = entity.userInfo[self.primaryKey ?? "primaryKey"]

            var first = true
            for attribute in entity.attributes {
                if first {
                    first = false
                } else {
                    sql += ",\n"
                }
                let attributeName = attribute.name(sqlite: sqliteLite, mapping: mapping)
                sql += "    \(attributeName) \(attribute.attributeType.sqliteName)"
                if !attribute.isOptional {
                    sql += " NOT NULL"
                }
                if attributeName == primaryKey {
                    sql += " PRIMARY KEY"
                }
            }
            sql += "\n);\n"
            log(sql)
        }
    }

    func log(_ message: String) {
        print(message)
    }

    func error(_ message: String) {
        print("❌ error: \(message)") // TODO: output in stderr
    }

}

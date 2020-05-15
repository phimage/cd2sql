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

    @Flag(help: "Add instruction IF NOT EXISTS when creating table")
    var ifNotExists: Bool

    @Option(help: "If table or field names contains space use this placeholder instead")
    var spacePlaceHolder: String?

    @Option(help: "A character to escape names (ex: ` or [])")
    var escape: String?

    func escapes() -> (Character, Character)? {
        guard let escape = self.escape else {
            return nil
        }
        guard let first = escape.first else {
            return nil
        }
        if let second = escape.dropFirst().first {
            return (first, second)
        } else {
            return (first, first)
        }
    }

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
        let escapes = self.escapes()

        for entity in parsedMom.model.entities {
            var tableName = entity.name(sqlite: sqliteLite, mapping: mapping)
            if let spacePlaceHolder = spacePlaceHolder {
                tableName = tableName.replacingOccurrences(of: " ", with: spacePlaceHolder)
            }
            if let escapes = escapes {
                tableName = "\(escapes.0)\(tableName)\(escapes.1)"
            }
            var sql = "CREATE TABLE"
            if ifNotExists {
                sql += " IF NOT EXISTS"
            }
            sql += " \(tableName) (\n"
            let primaryKey = entity.userInfo[self.primaryKey ?? "primaryKey"]

            var first = true
            for attribute in entity.attributes {
                if first {
                    first = false
                } else {
                    sql += ",\n"
                }
                var attributeName = attribute.name(sqlite: sqliteLite, mapping: mapping)
                if let spacePlaceHolder = spacePlaceHolder {
                    attributeName = attributeName.replacingOccurrences(of: " ", with: spacePlaceHolder)
                }
                if let escapes = escapes {
                    attributeName = "\(escapes.0)\(attributeName)\(escapes.1)"
                }
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

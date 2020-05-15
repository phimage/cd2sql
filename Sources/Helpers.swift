import Foundation
import MomXML

protocol MomType {
    var name: String {get}
    var sqliteName: String {get}
    var userInfo: MomUserInfo {get}
}

extension MomEntity: MomType {

    var sqliteName: String {
        return "Z\(name.uppercased())"
    }
}
extension MomAttribute: MomType {

    var sqliteName: String {
        return "Z\(name.uppercased())"
    }
}

extension MomType {
    func name(sqlite: Bool, mapping: String?) -> String {
        if sqlite {
            return self.sqliteName
        } else {
            if let mapping = mapping, let name = self.userInfo[mapping] {
                return name
            }
            return self.name
        }
    }
}

extension MomAttribute.AttributeType {

    var sqliteName: String {
        switch self {
        case .string, .uuid, .uri:
            return "VARCHAR"
        case .date:
            return "TIMESTAMP"
        case .integer16, .integer32, .integer64:
            return "INTEGER"
        case .boolean:
            return "INTEGER"
        case .float, .decimal:
            return "FLOAT"
        case .double:
            return "DOUBLE"
        case .binary, .transformable, .undefined:
            return "BLOB"
        case .objectID:
            return "VARCHAR"
        }
    }

    var sqlName: String {
        switch self {
        case .string, .uuid, .uri:
            return "VARCHAR"
        case .date:
            return "TIMESTAMP"
        case .integer16:
            return "INTEGER"
        case .integer32:
            return "INTEGER"
        case .integer64:
            return "INTEGER"
        case .boolean:
            return "INTEGER"
        case .float, .decimal:
            return "FLOAT"
        case .double:
            return "DOUBLE"
        case .binary, .transformable, .undefined:
            return "BLOB"
        case .objectID:
            return "VARCHAR"
        }
    }

    var sqlServerName: String {
        switch self {
        case .string, .uuid, .uri:
            return "VARCHAR"
        case .date:
            return "TIMESTAMP"
        case .integer16:
            return "smallint"
        case .integer32:
            return "int"
        case .integer64:
            return "bigint"
        case .boolean:
            return "tinyint"
        case .float, .decimal:
            return "FLOAT"
        case .double:
            return "DOUBLE"
        case .binary, .transformable, .undefined:
            return "BLOB"
        case .objectID:
            return "VARCHAR"
        }
    }
}

extension MomUserInfo {

    subscript(key: String) -> String? {
        for userInfo in self.entries {
            if userInfo.key == key {
                return userInfo.value
            }
        }
        return nil
    }
}

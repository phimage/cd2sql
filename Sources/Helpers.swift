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
        case .string:
            return "VARCHAR"
        case .date:
            return "TIMESTAMP"
        case .integer32:
            return "INTEGER"
        case .boolean:
            return "INTEGER"
        case .binary, .transformable:
            return "BLOB"
        default:
            return self.rawValue.uppercased()
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

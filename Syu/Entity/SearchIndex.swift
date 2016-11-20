import Foundation
import SQLite

struct SearchIndex {
    struct Column {
        static let id = Expression<Int64>("id")
        static let name = Expression<String>("name")
        static let type = Expression<Int64>("type")
        static let requestKey = Expression<String>("request_key")
    }

    enum type: Int {
        case unknown = 1
    }

    let name: String
    let type: Int64
    let requestKey: String
}

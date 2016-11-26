import Foundation
import SQLite

struct Map {
    struct Column {
        static let requestKey = Expression<String>("request_key")
        static let topicID = Expression<Int64>("topic_id")
        static let sourceLanguage = Expression<Int64>("source_language")
        static let referencePath = Expression<String>("reference_path")
    }

    let requestKey: String
    let topicID: Int64
    let sourceLanguage: Int64
    let referencePath: String
}

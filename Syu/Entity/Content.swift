import Foundation
import SQLite

struct Content {
    struct Column {
        static let requestKey = Expression<String>("request_key")
        static let topicID = Expression<Int64>("topic_id")
        static let referencePath = Expression<String>("reference_path")
    }

    let requestKey: String
    let topicID: Int64
    let referencePath: String
}

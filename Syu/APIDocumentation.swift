import Foundation
import SQLite

class APIDocumentation {
    let resourcesPath: URL

    var mapDBPath: URL {
        return resourcesPath.appendingPathComponent("external/map.db", isDirectory: false)
    }

    var cacheDBPath: URL {
        return resourcesPath.appendingPathComponent("external/cache.db", isDirectory: false)
    }

    var mapDB: Connection!
    var cacheDB: Connection!

    required init(xcodePath: URL) {
        resourcesPath = xcodePath.appendingPathComponent("../SharedFrameworks/DNTDocumentationSupport.framework/Resources", isDirectory: true).standardizedFileURL

        openDatabases()
    }

    convenience init?() {
        guard let xcodePath = Xcode.currentPath else {
            return nil
        }

        self.init(xcodePath: xcodePath)
    }

    private func openDatabases() {
        mapDB = try? Connection(mapDBPath.absoluteString, readonly: true)
        cacheDB = try? Connection(cacheDBPath.absoluteString, readonly: true)
    }

    func test() {
        let requestKeys = testMapDB()
        testCacheDB(requestKeys: requestKeys)
    }

    private func testMapDB() -> [String] {
        let map = Table("map")
        let requestKey = Expression<String>("request_key")
        let topicID = Expression<Int64>("topic_id")
        let referencePath = Expression<String>("reference_path")

        let query = map.select(requestKey, topicID, referencePath)
            .filter(referencePath.glob("uikit/uiviewcontroller*"))
            .limit(10)

        var requestKeys: [String] = []
        for record in try! mapDB.prepare(query) {
            print("key: \(record[requestKey]), topic: \(record[topicID]), path: \(record[referencePath])")
            requestKeys.append(record[requestKey])
        }
        return requestKeys
    }

    private func testCacheDB(requestKeys: [String]) {
        let response = Table("response")
        let requestKey = Expression<String>("request_key")
        let uncompressedSize = Expression<Int64>("uncompressed_size")
        let responseData = Expression<SQLite.Blob>("response_data")

        let query = response.select(requestKey, uncompressedSize, responseData)
                            .filter(requestKeys.contains(requestKey))

        for record in try! cacheDB.prepare(query) {
            let data = Data(bytes: record[responseData].bytes)

            print("key: \(record[requestKey]), uncompressedSize: \(record[uncompressedSize])")

            let dataString = String(data: data, encoding: String.Encoding.ascii)
            print(dataString)
        }
    }
}

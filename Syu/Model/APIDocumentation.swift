import Foundation
import Compression
import SQLite
import RxSwift

class APIDocumentation {
    let resourcesPath: URL

    var mapDBPath: URL {
        return resourcesPath.appendingPathComponent("external/map.db", isDirectory: false)
    }

    var cacheDBPath: URL {
        return resourcesPath.appendingPathComponent("external/cache.db", isDirectory: false)
    }

    var indexDBPath: URL {
        return SearchIndexCreator.indexFilePath
    }

    var mapDB: Connection!
    var cacheDB: Connection!
    var indexDB: Connection!

    required init(xcodePath: URL) {
        resourcesPath = xcodePath.appendingPathComponent("../SharedFrameworks/DNTDocumentationSupport.framework/Resources", isDirectory: true).standardizedFileURL
    }

    convenience init?() {
        guard let xcodePath = Xcode.currentPath else {
            return nil
        }

        self.init(xcodePath: xcodePath)
    }

    func prepare(completion: @escaping (() -> Void)) {
        createSearchIndexIfNeeded {
            self.openDatabases()
            completion()
        }
    }

    private func createSearchIndexIfNeeded(completion: @escaping (() -> Void)) {
        if SearchIndexCreator.existsIndexDB {
            completion()
        } else {
            let creator = SearchIndexCreator(resourcesPath: resourcesPath)
            creator.createIndex { _ in
                completion()
            }
        }
    }

    private func openDatabases() {
        mapDB = try? Connection(mapDBPath.absoluteString, readonly: true)
        cacheDB = try? Connection(cacheDBPath.absoluteString, readonly: true)
        indexDB = try? Connection(indexDBPath.absoluteString, readonly: true)
    }

    func search(keyword: String) -> Observable<[SearchIndex]> {
        let query = Table("search_indexes").select(SearchIndex.Column.name,
                                                   SearchIndex.Column.type,
                                                   SearchIndex.Column.requestKey)
            .filter(SearchIndex.Column.name.glob("\(keyword)*"))
            .limit(30)

        return Observable<[SearchIndex]>.create { observer in
            do {
                let indexes = try self.indexDB.prepare(query).map { record in
                    SearchIndex(name: record[SearchIndex.Column.name],
                                type: record[SearchIndex.Column.type],
                                requestKey: record[SearchIndex.Column.requestKey])
                }
                observer.onNext(indexes)
                observer.onCompleted()
            } catch let e {
                observer.onError(e)
            }
            return Disposables.create()
        }
    }

    func responseData(from key: String) -> String? {
        let requestKey = Expression<String>("request_key")
        let responseData = Expression<SQLite.Blob>("response_data")

        let query = Table("response").select(responseData).filter(requestKey == key)

        if let data = try? cacheDB.pluck(query)![responseData] {
            return String(data: decode(from: Data(bytes: data.bytes)), encoding: .utf8)
        }
        return nil
    }

    private func decode(from encodedData: Data) -> Data {
        let result = encodedData.withUnsafeBytes { (sourceBuffer: UnsafePointer<UInt8>) -> Data in
            let sourceBufferSize = encodedData.count
            let destBufferSize = 1048576
            let destBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destBufferSize)
            let size = compression_decode_buffer(destBuffer, destBufferSize, sourceBuffer, sourceBufferSize, nil, COMPRESSION_LZFSE)

            return Data(bytesNoCopy: destBuffer, count: size, deallocator: .free)
        }

        return result
    }
}

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

    func searchContents(keyword: String) -> Observable<[Content]> {
        let query = Table("map").select(Content.Column.requestKey, Content.Column.topicID, Content.Column.referencePath)
            .filter(Content.Column.referencePath.glob("\(keyword)*"))
            .limit(30)

        return Observable<[Content]>.create { observer in
            do {
                let contents = try self.mapDB.prepare(query).map { record in
                    Content(requestKey: record[Content.Column.requestKey],
                            topicID: record[Content.Column.topicID],
                            referencePath: record[Content.Column.referencePath])
                }
                observer.onNext(contents)
                observer.onCompleted()
            } catch let e {
                observer.onError(e)
            }
            return Disposables.create()
        }
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

import Foundation
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
        if SearchIndexCreator.existsIndexFile {
            completion()
        } else {
            let creator = SearchIndexCreator(resourcesPath: resourcesPath)
            creator.createSearchIndex { _ in
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

    func responseData(from key: String) -> ResponseData? {
        let requestKey = Expression<String>("request_key")
        let responseData = Expression<ResponseData>("response_data")

        let query = Table("response").select(responseData).filter(requestKey == key)

        if let row = try? cacheDB.pluck(query), let record = row {
            return record[responseData]
        } else {
            return nil
        }
    }
}

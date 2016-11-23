import Foundation
import SQLite
import Result

enum SearchIndexCreatorError: Error {
    case fileError(Error)
    case databaseError(Error)
}

class SearchIndexCreator {
    static var existsIndexFile: Bool {
        return FileManager.default.fileExists(atPath: indexFilePath.path)
    }

    static var indexFilePath: URL {
        return directoryPath.appendingPathComponent("apiDoc.idx")
    }

    static var directoryPath: URL {
        let appName = Bundle.main.infoDictionary!["CFBundleName"]!
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("\(appName)")
    }

    let resourcesPath: URL
    init(resourcesPath: URL) {
        self.resourcesPath = resourcesPath
    }

    func createSearchIndex(completion: @escaping (CreateSearchIndexResult) -> Void) {
        do {
            try FileManager.default.createDirectory(at: SearchIndexCreator.directoryPath, withIntermediateDirectories: true)
        } catch let error {
            completion(.failure(.fileError(error)))
            return
        }

        let connection: Connection
        let indexDBPathString = SearchIndexCreator.indexFilePath.absoluteString
        do {
            connection = try Connection(indexDBPathString)
        } catch let error {
            completion(.failure(.databaseError(error)))
            return
        }

        let searchIndexes = Table("search_indexes")
        let insertStatement: Statement
        do {
            try connection.run(searchIndexes.create { t in
                t.column(SearchIndex.Column.id, primaryKey: .autoincrement)
                t.column(SearchIndex.Column.name)
                t.column(SearchIndex.Column.type)
                t.column(SearchIndex.Column.requestKey)
            })

            try connection.run(searchIndexes.createIndex([
                SearchIndex.Column.name,
                SearchIndex.Column.type,
                SearchIndex.Column.requestKey
            ], unique: true, ifNotExists: true))

            insertStatement = try connection.prepare("insert into search_indexes (name, type, request_key) values (?, ?, ?)")
        } catch let error {
            completion(.failure(.databaseError(error)))
            return
        }

        let externalPath = resourcesPath.appendingPathComponent("external")
        if let contents = try? FileManager.default.contentsOfDirectory(at: externalPath, includingPropertiesForKeys: nil) {
            let indexFiles = contents.filter { $0.pathExtension == "txt" }
            do {
                for file in indexFiles {
                    try connection.transaction {
                        try self.parseRecords(from: file) { line in
                            let components = line.components(separatedBy: "\0")
                            let name = components[0]
                            let type = Int64(components[1])!
                            let requestKey = components[2]

                            try insertStatement.run([name, type, requestKey])
                        }
                    }
                }
            } catch let error {
                return completion(.failure(.databaseError(error)))
            }
        }
        completion(.success(SearchIndexCreator.indexFilePath))
    }

    func parseRecords(from url: URL, lineProcess: ((String) throws -> Void)) rethrows {
        guard let handle = try? FileHandle(forReadingFrom: url) else {
            assertionFailure("Cannot open file: \(url)")
            return
        }

        defer {
            handle.closeFile()
        }

        let bufferSize = 4096
        var buffer = Data(capacity: bufferSize)
        let delimiter = "\n".data(using: .utf8)!

        var eof = false
        while !eof {
            if let range = buffer.range(of: delimiter) {
                if let line = String(data: buffer.subdata(in: 0..<range.lowerBound), encoding: .utf8) {
                    try lineProcess(line)
                }
                buffer.removeSubrange(0..<range.upperBound)
                continue
            }
            let data = handle.readData(ofLength: bufferSize / 2)
            if data.count > 0 {
                buffer.append(data)
            } else {
                eof = true
                if buffer.count > 0 {
                    if let line = String(data: buffer, encoding: .utf8) {
                        try lineProcess(line)
                    }
                    buffer.count = 0
                    continue
                }
            }
        }
    }
}

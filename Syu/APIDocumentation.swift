import Foundation

struct APIDocumentation {
    let resourcesPath: URL

    var mapDBPath: URL {
        return resourcesPath.appendingPathComponent("external/map.db", isDirectory: false)
    }

    var cacheDBPath: URL {
        return resourcesPath.appendingPathComponent("external/cache.db", isDirectory: false)
    }

    init(xcodePath: URL) {
        resourcesPath = xcodePath.appendingPathComponent("../SharedFrameworks/DNTDocumentationSupport.framework/Resources", isDirectory: true).standardizedFileURL
    }

    init?() {
        guard let xcodePath = Xcode.currentPath else {
            return nil
        }

        self.init(xcodePath: xcodePath)
    }
}
